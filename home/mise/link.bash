# Link mise configuration to ~/.config/mise
#
# mise stores its global config in ~/.config/mise/
# We symlink the config.toml file so mise can still create its own runtime files

# Ensure ~/.config/mise directory exists
mkdir -p "$HOME/.config/mise"

# Link config.toml
link "$HOME_DIR/mise/config/config.toml" "$HOME/.config/mise/config.toml"

# Link settings.toml if it exists
if [[ -f "$HOME_DIR/mise/config/settings.toml" ]]; then
  link "$HOME_DIR/mise/config/settings.toml" "$HOME/.config/mise/settings.toml"
fi
