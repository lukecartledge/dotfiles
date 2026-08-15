#!/usr/bin/env bash

if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

SWIFTBAR_CHECKOUT="${SWIFTBAR_CHECKOUT:-$HOME/code/copilot-quota}"
SWIFTBAR_PLUGIN="$SWIFTBAR_CHECKOUT/copilot-quota.15m.sh"
SWIFTBAR_PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"

if [[ ! -f "$SWIFTBAR_PLUGIN" ]]; then
  if [[ $dry == "1" ]]; then
    log "Would link $SWIFTBAR_PLUGIN → $SWIFTBAR_PLUGIN_DIR/copilot-quota.15m.sh"
    return 0
  fi
  fail "SwiftBar plugin not found: $SWIFTBAR_PLUGIN"
  return 1
fi

mkdir -p "$SWIFTBAR_PLUGIN_DIR"
link "$SWIFTBAR_PLUGIN" "$SWIFTBAR_PLUGIN_DIR/copilot-quota.15m.sh"
