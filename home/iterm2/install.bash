#!/usr/bin/env bash
#
# iterm2/install.bash - Configure iTerm2 preferences via defaults write
#
# Sets shared global preferences and installs Dynamic Profiles.
# Machine-specific settings (EnableAPIServer, GPU, etc.) are left to
# each machine's own iTerm2 state.

if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

DOMAIN="com.googlecode.iterm2"
ITERM2_DIR="$HOME_DIR/iterm2"
DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

info "Configuring iTerm2 preferences..."

if [[ $dry == "1" ]]; then
  log "Would write iTerm2 global preferences via defaults"
  log "Would install Dynamic Profiles to $DYNAMIC_PROFILES_DIR"
  return 0
fi

# ---------------------------------------------------------------------------
# Global preferences
# ---------------------------------------------------------------------------

# Appearance
defaults write $DOMAIN AdjustWindowForFontSizeChange -bool false
defaults write $DOMAIN DimInactiveSplitPanes -bool true
defaults write $DOMAIN DimOnlyText -bool true
defaults write $DOMAIN DisableFullscreenTransparency -bool true
defaults write $DOMAIN HideFromDockAndAppSwitcher -bool false
defaults write $DOMAIN HideMenuBarInFullscreen -bool false
defaults write $DOMAIN HideScrollbar -bool true
defaults write $DOMAIN HideTabNumber -bool true
defaults write $DOMAIN ShowBookmarkName -bool false
defaults write $DOMAIN ShowFullScreenTabBar -bool false
defaults write $DOMAIN SplitPaneDimmingAmount -float 0.18748998397435898
defaults write $DOMAIN TabStyle -int 1
defaults write $DOMAIN TabStyleWithAutomaticOption -int 4
defaults write $DOMAIN TabTransform -int 0
defaults write $DOMAIN TabViewType -int 0
defaults write $DOMAIN UseBorder -bool false
defaults write $DOMAIN UseLionStyleFullscreen -bool false
defaults write $DOMAIN WindowNumber -bool true

# Behavior
defaults write $DOMAIN AllowClipboardAccess -bool true
defaults write $DOMAIN AlternateMouseScroll -bool true
defaults write $DOMAIN ConvertDosNewlines -bool false
defaults write $DOMAIN EscapeShellCharsWithBackslash -bool false
defaults write $DOMAIN JobName -bool true
defaults write $DOMAIN OnlyWhenMoreTabs -bool false
defaults write $DOMAIN PromptOnQuit -bool false
defaults write $DOMAIN SmartPlacement -bool true
defaults write $DOMAIN WordCharacters -string 'ewf'
defaults write $DOMAIN SeparateStatusBarsPerPane -bool false

# Paste
defaults write $DOMAIN AboutToPasteTabsWithCancel -bool true
defaults write $DOMAIN AboutToPasteTabsWithCancel_selection -int 3
defaults write $DOMAIN PasteSpecialRegex -string ''
defaults write $DOMAIN PasteSpecialSubstitution -string ''
defaults write $DOMAIN PasteSpecialUseRegexSubstitution -bool false
defaults write $DOMAIN PasteTabToStringTabStopSize -int 4
defaults write $DOMAIN QuickPasteBytesPerCall -int 1536
defaults write $DOMAIN QuickPasteDelayBetweenCalls -float 0.006666666362434626

# Bell / Feedback
defaults write $DOMAIN HapticFeedbackForEsc -bool false
defaults write $DOMAIN SoundForEsc -bool false
defaults write $DOMAIN VisualIndicatorForEsc -bool false

# Hotkey (Ctrl+X global hotkey)
defaults write $DOMAIN Hotkey -bool true
defaults write $DOMAIN HotkeyChar -int 120
defaults write $DOMAIN HotkeyCode -int 7
defaults write $DOMAIN HotkeyMigratedFromSingleToMulti -bool true
defaults write $DOMAIN HotkeyModifiers -int 262144

# tmux integration
defaults write $DOMAIN AutoHideTmuxClientSession -bool true
defaults write $DOMAIN ClosingTmuxTabKillsTmuxWindows -bool true
defaults write $DOMAIN ClosingTmuxTabKillsTmuxWindows_selection -int 1
defaults write $DOMAIN OpenTmuxWindowsIn -int 0
defaults write $DOMAIN TmuxUsesDedicatedProfile -bool true
defaults write $DOMAIN UseTmuxStatusBar -bool true

# Misc
defaults write $DOMAIN "Print In Black And White" -bool true
defaults write $DOMAIN ToolbeltTools -array 'Profiles'

# Disable LoadPrefsFromCustomFolder (we manage settings via this script now)
defaults write $DOMAIN LoadPrefsFromCustomFolder -bool false

success "Wrote iTerm2 global preferences"

# ---------------------------------------------------------------------------
# Dynamic Profiles directory (profiles symlinked via link.bash)
# ---------------------------------------------------------------------------

mkdir -p "$DYNAMIC_PROFILES_DIR"

# ---------------------------------------------------------------------------
# Remove static profiles that conflict with Dynamic Profiles
# ---------------------------------------------------------------------------

PREFS_PLIST="$HOME/Library/Preferences/$DOMAIN.plist"
if /usr/libexec/PlistBuddy -c "Print ':New Bookmarks'" "$PREFS_PLIST" &>/dev/null; then
  DYNAMIC_GUIDS=()
  if [[ -f "$ITERM2_DIR/profiles.plist" ]]; then
    i=0
    while guid=$(/usr/libexec/PlistBuddy -c "Print ':Profiles:${i}:Guid'" "$ITERM2_DIR/profiles.plist" 2>/dev/null); do
      DYNAMIC_GUIDS+=("$guid")
      (( i++ ))
    done
  fi

  if [[ ${#DYNAMIC_GUIDS[@]} -gt 0 ]]; then
    removed=0
    idx=0
    while /usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${idx}'" "$PREFS_PLIST" &>/dev/null; do
      (( idx++ ))
    done

    while (( idx-- > 0 )); do
      static_guid=$(/usr/libexec/PlistBuddy -c "Print ':New Bookmarks:${idx}:Guid'" "$PREFS_PLIST" 2>/dev/null)
      for dg in "${DYNAMIC_GUIDS[@]}"; do
        if [[ "$static_guid" == "$dg" ]]; then
          /usr/libexec/PlistBuddy -c "Delete ':New Bookmarks:${idx}'" "$PREFS_PLIST"
          (( removed++ ))
          break
        fi
      done
    done

    if (( removed > 0 )); then
      success "Removed $removed static profile(s) that conflict with Dynamic Profiles"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Custom color presets
# ---------------------------------------------------------------------------

if [[ -f "$ITERM2_DIR/color-presets.plist" ]]; then
  defaults write $DOMAIN "Custom Color Presets" -dict
  # Import the color preset plist by merging it into the domain
  /usr/libexec/PlistBuddy -c "Merge '$ITERM2_DIR/color-presets.plist' :'Custom Color Presets'" \
    "$HOME/Library/Preferences/$DOMAIN.plist" 2>/dev/null \
    && success "Imported custom color presets" \
    || info "Color presets import skipped (PlistBuddy not available or merge failed)"
fi

# ---------------------------------------------------------------------------
# Pointer actions
# ---------------------------------------------------------------------------

defaults write $DOMAIN PointerActions -dict \
  'Button,1,1,,' '<dict><key>Action</key><string>kContextMenuPointerAction</string></dict>' \
  'Button,2,1,,' '<dict><key>Action</key><string>kPasteFromSelectionPointerAction</string></dict>' \
  'Gesture,ThreeFingerSwipeDown,,' '<dict><key>Action</key><string>kPrevWindowPointerAction</string></dict>' \
  'Gesture,ThreeFingerSwipeLeft,,' '<dict><key>Action</key><string>kPrevTabPointerAction</string></dict>' \
  'Gesture,ThreeFingerSwipeRight,,' '<dict><key>Action</key><string>kNextTabPointerAction</string></dict>' \
  'Gesture,ThreeFingerSwipeUp,,' '<dict><key>Action</key><string>kNextWindowPointerAction</string></dict>'

success "Configured pointer actions"

info "Restart iTerm2 for changes to take effect"
