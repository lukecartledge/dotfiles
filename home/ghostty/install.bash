#!/usr/bin/env bash
#
# ghostty/install.bash - Register Ghostty as a hidden macOS Login Item
#
# WHY: The Ghostty config runs headless — `initial-window = false` and
# `quit-after-last-window-closed = false` mean the only entry point is the
# Quick Terminal global hotkey (Ctrl+X). For that hotkey to respond from a
# fresh boot, the Ghostty process must already be running. Registering it as
# a *hidden* Login Item launches it in the background at login with no window,
# just holding the hotkey — "headless at boot, Quick Terminal ready".
#
# Idempotent: skips if Ghostty is already a Login Item. macOS-only.
#
# Note: on first run macOS may prompt to allow the terminal to control
# "System Events" (Automation permission). Approve it, or add Ghostty
# manually via System Settings → General → Login Items.

if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

GHOSTTY_APP="/Applications/Ghostty.app"

if [[ ! -d "$GHOSTTY_APP" ]]; then
  info "Ghostty.app not installed — skipping Login Item registration"
  return 0
fi

# Idempotency: skip if Ghostty is already a Login Item
if osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null \
  | grep -q "Ghostty"; then
  success "Ghostty already registered as a Login Item"
  return 0
fi

if [[ $dry == "1" ]]; then
  log "Would register Ghostty as a hidden Login Item"
  return 0
fi

if osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$GHOSTTY_APP\", hidden:true}" >/dev/null 2>&1; then
  success "Registered Ghostty as a hidden Login Item"
else
  fail "Failed to register Ghostty as a Login Item (grant Automation permission for System Events, or add it manually)"
  return 1
fi
