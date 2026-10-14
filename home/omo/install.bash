#!/usr/bin/env bash
#
# omo/install.bash - Make On's shared skills available to OMP and OmO Native.
#
# The checkout is kept outside dotfiles so it can be updated independently.

ORG_CONFIG_DIR="$HOME/.local/share/onrunning/dev-tooling-config"

if [[ -d "$ORG_CONFIG_DIR/.git" ]]; then
  info "On dev-tooling-config already cloned"
  return 0 2>/dev/null || exit 0
fi

if ! command -v gh &>/dev/null; then
  info "gh not on PATH — skipping On dev-tooling-config clone"
  return 0 2>/dev/null || exit 0
fi

mkdir -p "$(dirname "$ORG_CONFIG_DIR")"
info "Cloning On dev-tooling-config for shared OMP/OmO skills..."
if gh repo clone onrunning/dev-tooling-config "$ORG_CONFIG_DIR" >/dev/null; then
  success "On dev-tooling-config cloned"
else
  info "Could not clone On dev-tooling-config — authenticate gh and re-run script/run"
fi
