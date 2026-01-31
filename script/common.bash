#!/usr/bin/env bash
#
# common.bash - Shared functions for dotfiles scripts

# Declare variables for dry-run support
declare cmd
declare dry

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log a message, prefixed with [DRY RUN] if in dry-run mode
function log {
  if [[ $dry == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN]${NC}: $*"
  else
    echo -e "$*"
  fi
}

# Log an info message
function info {
  echo -e "  ${BLUE}..${NC} $1"
}

# Log a success message
function success {
  echo -e "  ${GREEN}OK${NC} $1"
}

# Log an error message
function fail {
  echo -e "  ${RED}FAIL${NC} $1"
}

# Backup a file or directory
# Usage: backup <path>
function backup {
  local target=$1
  if [[ -e "$target" || -L "$target" ]]; then
    local backup_path="${target}.backup.$(date +%Y%m%d%H%M%S)"
    if [[ $dry == "1" ]]; then
      log "Would backup $target to $backup_path"
    else
      mv "$target" "$backup_path"
      success "Backed up $target to $backup_path"
    fi
  fi
}

# Create a symbolic link
# Usage: link <source> <destination>
# If destination exists:
#   - If it's already the correct symlink, skip
#   - Otherwise, backup and replace
function link {
  local src=$1
  local dst=$2

  # Check if source exists
  if [[ ! -e "$src" ]]; then
    fail "Source does not exist: $src"
    return 1
  fi

  # If destination exists or is a symlink
  if [[ -e "$dst" || -L "$dst" ]]; then
    # Check if it's already the correct symlink
    if [[ -L "$dst" ]]; then
      local current_src
      current_src=$(readlink "$dst")
      if [[ "$current_src" == "$src" ]]; then
        success "Already linked: $dst"
        return 0
      fi
    fi

    # Backup existing file/directory
    backup "$dst"
  fi

  # Create parent directory if needed
  local dst_dir
  dst_dir=$(dirname "$dst")
  if [[ ! -d "$dst_dir" ]]; then
    if [[ $dry == "1" ]]; then
      log "Would create directory: $dst_dir"
    else
      mkdir -p "$dst_dir"
    fi
  fi

  # Create the symlink
  if [[ $dry == "1" ]]; then
    log "Would link $src → $dst"
  else
    ln -snf "$src" "$dst"
    success "Linked $src → $dst"
  fi
}

# Link a config directory to ~/.config/<name>
# Usage: link_config <source_dir> <config_name>
function link_config {
  local src=$1
  local name=$2
  link "$src" "$HOME/.config/$name"
}

# Link a dotfile to home directory
# Usage: link_home <source_file> <dotfile_name>
# The dotfile_name should NOT include the leading dot
function link_home {
  local src=$1
  local name=$2
  link "$src" "$HOME/.$name"
}
