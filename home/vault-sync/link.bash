#!/usr/bin/env bash
#
# Install the vault-sync launchd agent. Mighty Mini only: it's the one machine
# that runs Remindian and writes to the vault while Obsidian may be closed.
#
# The plist is rendered (not symlinked) because launchd needs absolute paths.

if [[ "$(uname -s)" != "Darwin" ]] || [[ "$(scutil --get LocalHostName 2>/dev/null)" != "Mighty-Mini" ]]; then
  return 0
fi

VAULT_SYNC_LABEL="com.lukecartledge.vault-sync"
VAULT_SYNC_TEMPLATE="$HOME_DIR/vault-sync/$VAULT_SYNC_LABEL.plist.template"
VAULT_SYNC_PLIST="$HOME/Library/LaunchAgents/$VAULT_SYNC_LABEL.plist"

if [[ $dry == "1" ]]; then
  log "Would render $VAULT_SYNC_TEMPLATE → $VAULT_SYNC_PLIST and reload $VAULT_SYNC_LABEL"
  return 0
fi

mkdir -p "$(dirname "$VAULT_SYNC_PLIST")"
sed "s|__HOME__|$HOME|g" "$VAULT_SYNC_TEMPLATE" > "$VAULT_SYNC_PLIST"
launchctl bootout "gui/$UID/$VAULT_SYNC_LABEL" 2>/dev/null || true
if launchctl bootstrap "gui/$UID" "$VAULT_SYNC_PLIST"; then
  success "Loaded launchd agent: $VAULT_SYNC_LABEL"
else
  fail "Could not load launchd agent: $VAULT_SYNC_LABEL"
  return 1
fi
