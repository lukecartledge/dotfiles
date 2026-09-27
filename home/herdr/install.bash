#!/usr/bin/env bash
#
# herdr/install.bash - Install herdr's agent-state integrations
#
# Each integration is a hook/plugin herdr writes into the agent's own config
# (Claude hooks, an opencode plugin, an omp extension) so the sidebar can show
# agent status. Runs after the agent packages in PACKAGES so it writes into
# the linked config rather than a file link.bash would later replace.
#
# Idempotent: only installs integrations that aren't already current.

if ! command -v herdr &>/dev/null; then
  info "herdr not on PATH yet — skipping integrations. Re-run script/run after brew bundle."
  return 0 2>/dev/null || exit 0
fi

herdr_status=$(herdr integration status 2>/dev/null)

for agent in claude opencode omp; do
  command -v "$agent" &>/dev/null || continue

  if grep -q "^$agent: current" <<<"$herdr_status"; then
    success "herdr $agent integration already current"
  elif herdr integration install "$agent" &>/dev/null; then
    success "herdr $agent integration installed"
  else
    fail "herdr $agent integration failed — run 'herdr integration install $agent'"
  fi
done
