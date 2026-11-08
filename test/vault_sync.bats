#!/usr/bin/env bats
#
# Tests for home/vault-sync/vault-sync.bash

# Not helpers/setup: it sources script/common.bash, whose fail() replaces the
# one bats-assert reports through, so failed assertions would pass silently.
REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
load "$REPO_ROOT/test/test_helper/bats-support/load"
load "$REPO_ROOT/test/test_helper/bats-assert/load"

SCRIPT="$REPO_ROOT/home/vault-sync/vault-sync.bash"

git_identity() {
  git -C "$1" config user.name "Vault Sync Test"
  git -C "$1" config user.email "vault-sync@example.com"
  git -C "$1" config commit.gpgsign false
}

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME"

  git init -q --bare -b main "$TEST_TMPDIR/remote.git"

  # Seed the remote with one commit so both clones start on main
  local seed="$TEST_TMPDIR/seed"
  git clone -q "$TEST_TMPDIR/remote.git" "$seed" 2>/dev/null
  git_identity "$seed"
  git -C "$seed" symbolic-ref HEAD refs/heads/main
  echo "start" > "$seed/shared.md"
  git -C "$seed" add -A
  git -C "$seed" commit -q -m "seed"
  git -C "$seed" push -q origin main

  export VAULT_DIR="$TEST_TMPDIR/vault"
  OTHER="$TEST_TMPDIR/other"
  git clone -q "$TEST_TMPDIR/remote.git" "$VAULT_DIR"
  git clone -q "$TEST_TMPDIR/remote.git" "$OTHER"
  git_identity "$VAULT_DIR"
  git_identity "$OTHER"

  export VAULT_SYNC_APP="vault-sync-test-none"
  export VAULT_SYNC_LOG="$TEST_TMPDIR/logs/sync.log"

  # Stubs record their arguments, and keep tests away from the real ssh agent
  STUB_DIR="$TEST_TMPDIR/stubs"
  CALLS="$TEST_TMPDIR/calls.log"
  mkdir -p "$STUB_DIR"
  printf '#!/bin/sh\necho "ssh-add $*" >> "%s"\n' "$CALLS" > "$STUB_DIR/ssh-add"
  chmod +x "$STUB_DIR/ssh-add"
  export PATH="$STUB_DIR:$PATH"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

remote_head() {
  git -C "$TEST_TMPDIR/remote.git" rev-parse main
}

@test "vault-sync: commits and pushes local changes" {
  echo "x" > "$VAULT_DIR/note.md"

  run "$SCRIPT"
  assert_success

  run git -C "$TEST_TMPDIR/remote.git" log -1 --format=%s main
  assert_output --regexp '^vault backup: [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9:]{8} \(vault-sync@.+\)$'
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "ok: committed and pushed"
}

@test "vault-sync: pulls upstream changes when clean" {
  echo "upstream" > "$OTHER/upstream.md"
  git -C "$OTHER" add -A
  git -C "$OTHER" commit -q -m "upstream change"
  git -C "$OTHER" push -q origin main

  run "$SCRIPT"
  assert_success

  [ -f "$VAULT_DIR/upstream.md" ]
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "ok: pulled upstream changes"
}

@test "vault-sync: reports nothing to do" {
  local before
  before="$(remote_head)"

  run "$SCRIPT"
  assert_success

  [ "$(remote_head)" = "$before" ]
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "ok: nothing to do"
}

@test "vault-sync: skips when the app is running" {
  sleep 30 3>&- &
  local app_pid=$!
  export VAULT_SYNC_APP="sleep"
  echo "x" > "$VAULT_DIR/note.md"
  local before
  before="$(remote_head)"

  run "$SCRIPT"
  kill "$app_pid"
  assert_success

  [ "$(remote_head)" = "$before" ]
  [ -z "$(git -C "$VAULT_DIR" log origin/main..HEAD --oneline)" ]
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "skip: obsidian running"
}

@test "vault-sync: skips when git index is locked" {
  touch "$VAULT_DIR/.git/index.lock"
  echo "x" > "$VAULT_DIR/note.md"
  local before
  before="$(remote_head)"

  run "$SCRIPT"
  assert_success

  [ "$(remote_head)" = "$before" ]
  [ -z "$(git -C "$VAULT_DIR" log origin/main..HEAD --oneline)" ]
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "skip: git locked"
}

@test "vault-sync: skips when a merge is in progress" {
  git -C "$VAULT_DIR" rev-parse HEAD > "$VAULT_DIR/.git/MERGE_HEAD"
  echo "x" > "$VAULT_DIR/note.md"
  local head_before
  head_before="$(git -C "$VAULT_DIR" rev-parse HEAD)"

  run "$SCRIPT"
  assert_failure

  [ "$(git -C "$VAULT_DIR" rev-parse HEAD)" = "$head_before" ]
  run git -C "$VAULT_DIR" status --porcelain
  assert_output "?? note.md"
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error: merge in progress"
}

@test "vault-sync: skips when not on main" {
  git -C "$VAULT_DIR" checkout -q -b other-branch
  echo "x" > "$VAULT_DIR/note.md"
  local head_before
  head_before="$(git -C "$VAULT_DIR" rev-parse HEAD)"

  run "$SCRIPT"
  assert_success

  [ "$(git -C "$VAULT_DIR" rev-parse HEAD)" = "$head_before" ]
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "skip: not on main"
}

@test "vault-sync: aborts merge and logs on conflict" {
  echo "theirs" > "$OTHER/shared.md"
  git -C "$OTHER" commit -q -am "upstream edit"
  git -C "$OTHER" push -q origin main
  echo "mine" > "$VAULT_DIR/shared.md"

  run "$SCRIPT"
  assert_failure

  [ ! -e "$VAULT_DIR/.git/MERGE_HEAD" ]
  run git -C "$VAULT_DIR" log -1 --format=%s
  assert_output --partial "vault backup:"
  run cat "$VAULT_DIR/shared.md"
  assert_output "mine"
  run cat "$VAULT_SYNC_LOG"
  assert_output --regexp '^[^
]+ error: pull conflict, merge aborted$'
}

@test "vault-sync: errors when vault is missing" {
  export VAULT_DIR="$TEST_TMPDIR/nope"

  run "$SCRIPT"
  assert_failure

  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error:"
}

@test "vault-sync: logs push failure" {
  printf '#!/bin/sh\nexit 1\n' > "$TEST_TMPDIR/remote.git/hooks/pre-receive"
  chmod +x "$TEST_TMPDIR/remote.git/hooks/pre-receive"
  echo "x" > "$VAULT_DIR/note.md"

  run "$SCRIPT"
  assert_failure

  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error: push failed"
}

@test "vault-sync: logs pull failure without a conflict" {
  git -C "$VAULT_DIR" remote set-url origin "$TEST_TMPDIR/missing.git"

  run "$SCRIPT"
  assert_failure

  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error: pull failed"
}

@test "vault-sync: logs commit failure" {
  printf '#!/bin/sh\nexit 1\n' > "$VAULT_DIR/.git/hooks/pre-commit"
  chmod +x "$VAULT_DIR/.git/hooks/pre-commit"
  echo "x" > "$VAULT_DIR/note.md"

  run "$SCRIPT"
  assert_failure

  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error: commit failed"
}

@test "vault-sync: refuses to commit unresolved conflicts" {
  echo "stashed" > "$VAULT_DIR/shared.md"
  git -C "$VAULT_DIR" stash -q
  echo "committed" > "$VAULT_DIR/shared.md"
  git -C "$VAULT_DIR" commit -q -am "local edit"
  git -C "$VAULT_DIR" stash pop -q 2>/dev/null || true
  [ ! -e "$VAULT_DIR/.git/MERGE_HEAD" ]
  local before
  before="$(remote_head)"

  run "$SCRIPT"
  assert_failure

  [ "$(remote_head)" = "$before" ]
  run git -C "$VAULT_DIR" log -1 --format=%s
  assert_output "local edit"
  run tail -1 "$VAULT_SYNC_LOG"
  assert_output --partial "error: unresolved conflicts"
}

@test "vault-sync: loads keychain ssh keys before committing" {
  echo "x" > "$VAULT_DIR/note.md"

  run "$SCRIPT"
  assert_success

  run cat "$CALLS"
  assert_output --partial "ssh-add --apple-load-keychain"
}
