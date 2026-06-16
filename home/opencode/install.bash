#!/usr/bin/env bash
#
# opencode/install.bash - Install the context-mode CLI
#
# opencode.json references context-mode as both a plugin and an MCP
# server (command: ["context-mode"]). Without the global binary on
# PATH, opencode loads neither and the AGENTS.md context-mode routing
# rules point at tools that don't exist. Installed via npm, so this
# depends on mise having provisioned node first (mise is processed
# before opencode in the host PACKAGES order).
#
# Idempotent: skips if the binary is already present.

if command -v context-mode &>/dev/null; then
  success "context-mode already installed"
  return 0 2>/dev/null || exit 0
fi

if ! command -v npm &>/dev/null; then
  info "npm not on PATH yet — skipping context-mode. Re-run script/run after mise provisions node."
  return 0 2>/dev/null || exit 0
fi

info "Installing context-mode globally via npm..."
if npm install -g context-mode &>/dev/null; then
  success "context-mode installed"
else
  fail "context-mode install failed — run 'npm install -g context-mode' manually"
fi
