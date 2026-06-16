#!/usr/bin/env bash
#
# mise/install.bash - Install mise-managed runtime versions
#
# Reads tool versions from ~/.config/mise/config.toml. Defensive about
# config presence: ensures the symlink exists before invoking mise,
# in case install.bash runs before link.bash (current script/run order).
#
# On a partial failure (a single tool fails to build), warn and let
# subsequent script/run packages still process — one bad pin shouldn't
# brick the rest of the bootstrap.

MISE_CONFIG_DIR="$HOME/.config/mise"
MISE_CONFIG="$MISE_CONFIG_DIR/config.toml"

mkdir -p "$MISE_CONFIG_DIR"
if [[ ! -e "$MISE_CONFIG" ]]; then
  ln -snf "$HOME_DIR/mise/config/config.toml" "$MISE_CONFIG"
fi

if ! command -v mise &>/dev/null; then
  info "mise not on PATH yet — skipping. Re-run script/run after Brewfile installs mise."
  return 0 2>/dev/null || exit 0
fi

info "Installing mise-managed tool versions..."
if mise install; then
  success "mise tools installed"
else
  fail "Some mise tools failed to install — see output above"
  info "Continuing bootstrap. Run 'mise list' to inspect, 'mise install' to retry."
fi
