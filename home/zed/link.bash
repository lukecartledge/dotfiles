# Link Zed configuration to ~/.config/zed
#
# Zed stores its config in ~/.config/zed/ on macOS
# We symlink individual files rather than the whole directory
# so Zed can still create its own runtime files (conversations, embeddings, etc.)

# Ensure ~/.config/zed directory exists
mkdir -p "$HOME/.config/zed"

# Link settings.json
link "$HOME_DIR/zed/config/settings.json" "$HOME/.config/zed/settings.json"

# Link keymap.json if it exists
if [[ -f "$HOME_DIR/zed/config/keymap.json" ]]; then
  link "$HOME_DIR/zed/config/keymap.json" "$HOME/.config/zed/keymap.json"
fi

# Link tasks.json if it exists
if [[ -f "$HOME_DIR/zed/config/tasks.json" ]]; then
  link "$HOME_DIR/zed/config/tasks.json" "$HOME/.config/zed/tasks.json"
fi

# Link themes directory if it exists
if [[ -d "$HOME_DIR/zed/config/themes" ]]; then
  link "$HOME_DIR/zed/config/themes" "$HOME/.config/zed/themes"
fi

# Link prompts directory if it exists
if [[ -d "$HOME_DIR/zed/config/prompts" ]]; then
  link "$HOME_DIR/zed/config/prompts" "$HOME/.config/zed/prompts"
fi
