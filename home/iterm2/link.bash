if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DYNAMIC_PROFILES_DIR"
link "$HOME_DIR/iterm2/profiles.plist" "$DYNAMIC_PROFILES_DIR/dotfiles-profiles.plist"

# Clean up backup files from DynamicProfiles directory.
# iTerm reads ALL plist files in this folder, so stale backups
# created by the link() function cause GUID conflicts.
rm -f "$DYNAMIC_PROFILES_DIR"/*.backup.* 2>/dev/null
