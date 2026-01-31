# Host configuration for Luke's MacBook Pro
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

  # Shell
  zsh

  # Version control
  git

  # Editors
  editors
  vim
  zed

  # Terminal
  tmux
  iterm2

  # Languages & Tools
  mise
  ruby
)
