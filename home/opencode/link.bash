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

# V2 terminal settings (including keybindings).
link "$HOME_DIR/opencode/config/cli.json" "$HOME/.config/opencode/cli.json"

# Link AGENTS.md (global agent instructions)
link "$HOME_DIR/shared/agent-instructions-core.md" "$HOME/.config/opencode/AGENTS.md"

# OpenCode-only guidance; the shared core instructs agents to read this file.
link "$HOME_DIR/opencode/config/AGENTS.md" "$HOME/.config/opencode/APPEND_SYSTEM.md"

# Link commands directory (custom slash commands)
link "$HOME_DIR/opencode/config/commands" "$HOME/.config/opencode/commands"

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
# Skills live in the Obsidian vault at ~/notes/brain — must be cloned
# separately. Skip with a clear warning if the vault isn't present, so
# bootstrap doesn't silently leave opencode without skills.
BRAIN_SKILLS="$HOME/notes/brain/40-skills"
if [[ -d "$BRAIN_SKILLS" ]]; then
  link "$BRAIN_SKILLS/custom" "$HOME/.config/opencode/skills/custom"
  link "$BRAIN_SKILLS/gathered" "$HOME/.config/opencode/skills/gathered"
else
  # shellcheck disable=SC2088  # tilde in user-facing string is intentional
  fail "~/notes/brain not found — opencode skills NOT linked"
  info "Clone the brain vault then re-run script/run to enable skills:"
  # shellcheck disable=SC2088  # tilde in user-facing string is intentional
  info "  git clone <brain-vault-remote> ~/notes/brain"
fi
