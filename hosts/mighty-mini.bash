# Host configuration for Mighty Mini
#
# This file defines which packages to install and configure on this machine.
# The PACKAGES array determines which home/{package} directories will be
# processed by script/run.

export SYSTEM="macos"

# Packages to install and configure
# Order matters: packages are processed in order listed
export PACKAGES=(
  # Core system
  system
  functions
  ssh
  smb

  # Shell
  zsh
  starship

  # Version control
  git

  # Editors
  editors
  vim
  zed

  # Languages & Tools
  # Ahead of Terminal on purpose: tmux/install.bash builds tmuxship with
  # cargo, which arrives with mise's rust toolchain. Behind it, a clean
  # bootstrap skips tmuxship and needs a second script/run.
  mise
  ruby

  # Terminal
  tmux
  iterm2
  ghostty
  swiftbar-package

  # AI
  opencode
  claude
)
