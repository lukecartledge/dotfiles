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

# Link tui.json (declares opencode terminal ui configuration)
link "$HOME_DIR/opencode/config/tui.json" "$HOME/.config/opencode/tui.json"

# Link oh-my-openagent.json (agent and category model configuration)
link "$HOME_DIR/opencode/config/oh-my-openagent.json" "$HOME/.config/opencode/oh-my-openagent.json"

# Link AGENTS.md (global agent instructions)
link "$HOME_DIR/opencode/config/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"

# Link commands directory (custom slash commands)
link "$HOME_DIR/opencode/config/commands" "$HOME/.config/opencode/commands"

# Link plugins directory (custom opencode plugins)
link "$HOME_DIR/opencode/config/plugins" "$HOME/.config/opencode/plugins"

# Link prompts directory (ECC agent prompt definitions)
link "$HOME_DIR/opencode/config/prompts" "$HOME/.config/opencode/prompts"

# Link instructions directory (ECC instruction files)
link "$HOME_DIR/opencode/config/instructions" "$HOME/.config/opencode/instructions"

# Link per-machine MCP overlay
# Work machines (On-*) get noop overlay; personal machines disable work MCPs
# Set OPENCODE_CONFIG=$HOME/.config/opencode/opencode.local.json in your .localrc
if [[ "$CURR_HOST" == On-* ]]; then
  link "$HOME_DIR/opencode/config/opencode.work.json" "$HOME/.config/opencode/opencode.local.json"
else
  link "$HOME_DIR/opencode/config/opencode.personal.json" "$HOME/.config/opencode/opencode.local.json"
fi

# Link skills directory (reusable skill definitions)
link "$HOME/notes/brain/40-skills/custom" "$HOME/.config/opencode/skills/custom"
link "$HOME/notes/brain/40-skills/gathered" "$HOME/.config/opencode/skills/gathered"
