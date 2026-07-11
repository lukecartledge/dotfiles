#!/usr/bin/env bash
#
# tmux/install.bash - Install TPM (tmux plugin manager) and declared plugins
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

if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  info "Installing tmux plugins..."
  "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 \
    && success "tmux plugins installed" \
    || fail "Some tmux plugins failed — open tmux and run: prefix + I"
fi
