# Link opencode configuration to ~/.config/opencode
#
# opencode stores its config in ~/.config/opencode/ on macOS
# We symlink individual files rather than the whole directory
# so opencode can still create its own runtime files (node_modules, bun.lock, etc.)

# Ensure ~/.config/opencode directory exists
mkdir -p "$HOME/.config/opencode"

# Link package.json (declares plugins and permissions)
link "$HOME_DIR/opencode/config/package.json" "$HOME/.config/opencode/package.json"

# Link opencode.json (main opencode configuration)
link "$HOME_DIR/opencode/config/opencode.json" "$HOME/.config/opencode/opencode.json"

# Link oh-my-opencode.json (agent and category model configuration)
link "$HOME_DIR/opencode/config/oh-my-opencode.json" "$HOME/.config/opencode/oh-my-opencode.json"
