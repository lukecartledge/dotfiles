# Configure iTerm2 to load preferences from dotfiles
#
# iTerm2 stores preferences in ~/Library/Preferences/com.googlecode.iterm2.plist
# We can configure it to load preferences from a custom folder instead.
#
# This script:
# 1. Sets up iTerm2 to load preferences from our dotfiles
# 2. The actual preferences file (com.googlecode.iterm2.plist) should be
#    exported from iTerm2 and placed in this directory

# Only run on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

ITERM2_PREFS_DIR="$HOME_DIR/iterm2"

# Tell iTerm2 to use custom preferences folder
# This requires iTerm2 to be restarted to take effect
if [[ $dry == "1" ]]; then
  log "Would configure iTerm2 to load preferences from $ITERM2_PREFS_DIR"
else
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  success "Configured iTerm2 to load preferences from $ITERM2_PREFS_DIR"
  info "Restart iTerm2 for changes to take effect"
fi
