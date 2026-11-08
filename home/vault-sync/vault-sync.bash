#!/usr/bin/env bash
#
# vault-sync.bash - Commit, pull and push the Obsidian vault while Obsidian is closed
#
# Run every few minutes by launchd on Mighty Mini, so writes made while
# Obsidian is closed (Remindian, agents) still reach GitHub. Stands aside when
# Obsidian is running (obsidian-git owns the repo then), when git holds its
# index lock, mid-merge, or when the vault is on another branch.
#
# Environment:
#   VAULT_DIR          vault repository  (default: $HOME/notes/brain)
#   VAULT_SYNC_LOG     log file          (default: $HOME/Library/Logs/vault-sync.log)
#   VAULT_SYNC_APP     process name for pgrep -x (default: Obsidian)
#   VAULT_SYNC_BRANCH  branch to sync    (default: main)
#
# Writes one line per run to the log: "<ISO-8601 time> <skip|ok|error>: <detail>".
# Exit codes: 0 for skip, nothing to do or success; 1 for an error.

set -Eeuo pipefail

VAULT_DIR="${VAULT_DIR:-$HOME/notes/brain}"
VAULT_SYNC_LOG="${VAULT_SYNC_LOG:-$HOME/Library/Logs/vault-sync.log}"
VAULT_SYNC_APP="${VAULT_SYNC_APP:-Obsidian}"
VAULT_SYNC_BRANCH="${VAULT_SYNC_BRANCH:-main}"

log() {
  mkdir -p "$(dirname "$VAULT_SYNC_LOG")"
  printf '%s %s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$*" >> "$VAULT_SYNC_LOG"
}

trap 'log "error: unexpected failure at line $LINENO"' ERR

vgit() {
  git -C "$VAULT_DIR" "$@"
}

main() {
  if [[ ! -e "$VAULT_DIR/.git" ]]; then
    log "error: no git repository at $VAULT_DIR"
    exit 1
  fi
  if pgrep -x "$VAULT_SYNC_APP" > /dev/null; then
    log "skip: obsidian running"
    return 0
  fi
  if [[ -e "$VAULT_DIR/.git/index.lock" ]]; then
    log "skip: git locked"
    return 0
  fi
  if [[ -e "$VAULT_DIR/.git/MERGE_HEAD" ]]; then
    log "error: merge in progress"
    exit 1
  fi
  if [[ "$(vgit rev-parse --abbrev-ref HEAD)" != "$VAULT_SYNC_BRANCH" ]]; then
    log "skip: not on $VAULT_SYNC_BRANCH"
    return 0
  fi
  # A conflicted stash pop or cherry-pick leaves no MERGE_HEAD; never commit its markers
  if [[ -n "$(vgit ls-files -u)" ]]; then
    log "error: unresolved conflicts"
    exit 1
  fi

  # After a reboot the agent is empty until something uses ssh, and signing
  # commits needs the key. Fail fast rather than hang on a prompt or a dead link.
  ssh-add --apple-load-keychain -q 2> /dev/null || true
  export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=15 -o ServerAliveCountMax=2"

  local committed=0
  vgit add -A
  if [[ -n "$(vgit diff --cached --name-only)" ]]; then
    local message
    message="vault backup: $(date '+%Y-%m-%d %H:%M:%S') (vault-sync@$(hostname -s))"
    if ! vgit commit -q -m "$message"; then
      log "error: commit failed"
      exit 1
    fi
    committed=1
  fi

  local before
  before="$(vgit rev-parse HEAD)"
  if ! vgit pull -q --no-rebase --no-edit; then
    if [[ -e "$VAULT_DIR/.git/MERGE_HEAD" ]]; then
      vgit merge --abort
      log "error: pull conflict, merge aborted"
    else
      log "error: pull failed"
    fi
    exit 1
  fi

  if ! vgit push -q; then
    log "error: push failed"
    exit 1
  fi

  if [[ $committed == 1 ]]; then
    log "ok: committed and pushed"
  elif [[ "$(vgit rev-parse HEAD)" != "$before" ]]; then
    log "ok: pulled upstream changes"
  else
    log "ok: nothing to do"
  fi
}

main "$@"
