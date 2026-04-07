if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DYNAMIC_PROFILES_DIR"
link "$HOME_DIR/iterm2/profiles.plist" "$DYNAMIC_PROFILES_DIR/dotfiles-profiles.plist"
