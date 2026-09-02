#!/usr/bin/env bash
#
# tmux/install.bash - Install tmuxship and TPM (tmux plugin manager) + plugins
#
# Plugins are declared in tmux.conf (@tpm_plugins) and loaded at the bottom via
# `run '~/.tmux/plugins/tpm/tpm'`. TPM is not vendored, so clone it and install
# the plugins here. install.bash runs before link.bash in script/run, so ensure
# ~/.tmux.conf exists first — TPM reads the plugin list from it. Non-fatal: a
# plugin fetch failure shouldn't brick the rest of bootstrap.

TPM_DIR="$HOME/.tmux/plugins/tpm"

if ! command -v git &>/dev/null; then
  info "git not on PATH yet — skipping tmux plugins. Re-run script/run later."
  return 0 2>/dev/null || exit 0
fi

# TPM reads @tpm_plugins from ~/.tmux.conf; link.bash runs after us, so pre-link.
if [[ ! -e "$HOME/.tmux.conf" ]]; then
  ln -snf "$HOME_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

if [[ ! -d "$TPM_DIR" ]]; then
  info "Installing TPM (tmux plugin manager)..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" \
    && success "TPM installed" \
    || fail "TPM clone failed — run: git clone https://github.com/tmux-plugins/tpm $TPM_DIR"
fi

if command -v tmux &>/dev/null && [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  info "Installing tmux plugins..."
  # install_plugins reads TPM's TMUX_PLUGIN_MANAGER_PATH from a running server
  # that has sourced tmux.conf — start a throwaway session so the var gets set.
  tmux new-session -d -s __tpm_install 2>/dev/null
  "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 \
    && success "tmux plugins installed" \
    || fail "Some tmux plugins failed — open tmux and run: prefix + I"
  tmux kill-session -t __tpm_install 2>/dev/null
fi

# tmuxship renders the status bar from starship configs (see tmuxship.toml).
#
# Installed from git, not crates.io: the released 0.1.3 predates the unified
# [left]/[center]/[right] config layout that tmuxship.toml uses, and would fall
# back to rendering starship's default prompt instead. Revisit when a release
# above 0.1.3 lands.
#
# cargo comes from mise's rust toolchain, which the `mise` package installs — if
# that has not run yet, skip rather than failing bootstrap; tmux.conf degrades to
# an unstyled status bar when the binary is absent.
TMUXSHIP_REPO="https://github.com/Yukaii/tmuxship"

if ! command -v cargo &>/dev/null; then
  info "cargo not on PATH yet — skipping tmuxship. Re-run script/run after mise."
elif command -v tmuxship &>/dev/null; then
  success "tmuxship already installed (cargo install --git $TMUXSHIP_REPO to update)"
else
  info "Installing tmuxship from git..."
  cargo install --git "$TMUXSHIP_REPO" --locked \
    && success "tmuxship installed" \
    || fail "tmuxship install failed — run: cargo install --git $TMUXSHIP_REPO --locked"
fi
