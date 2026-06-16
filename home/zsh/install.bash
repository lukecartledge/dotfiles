#!/usr/bin/env bash
#
# zsh/install.bash - Install oh-my-zsh framework and powerlevel10k theme
#
# Both are sourced by zshrc/oh-my-zsh.zsh; without them, the first
# shell login fails with "source: no such file" errors.

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  success "oh-my-zsh already installed"
else
  info "Installing oh-my-zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "oh-my-zsh installed"
fi

P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
  success "powerlevel10k already installed"
else
  info "Cloning powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  success "powerlevel10k installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

AUTOSUGGEST_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGGEST_DIR" ]]; then
  success "zsh-autosuggestions plugin already installed"
else
  info "Cloning zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGEST_DIR"
  success "zsh-autosuggestions installed"
fi

SYNTAXHL_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ -d "$SYNTAXHL_DIR" ]]; then
  success "zsh-syntax-highlighting plugin already installed"
else
  info "Cloning zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAXHL_DIR"
  success "zsh-syntax-highlighting installed"
fi
