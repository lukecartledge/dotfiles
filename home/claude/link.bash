# Link Claude Code configuration to ~/.claude
#
# Claude Code (v2.1.157+) reads ~/.claude/skills/ as a plugins directory.
# Each subdirectory must be a plugin with .claude-plugin/plugin.json. Skills
# inside the plugin live at {plugin}/skills/{skill-name}/SKILL.md (one level).
#
# Strategy: a single "vault" aggregator plugin whose skills/ directory contains
# flat symlinks to every skill in ~/notes/brain/40-skills/{custom,gathered}/.
# Claude Code's scanner only walks one level deep inside skills/, so the
# bucketing (custom vs gathered) is flattened away on the Claude Code side.

PLUGIN_DIR="$HOME/.claude/skills/vault"
mkdir -p "$PLUGIN_DIR/.claude-plugin" "$PLUGIN_DIR/skills"

# Write the plugin manifest (idempotent — overwrite each link run)
cat > "$PLUGIN_DIR/.claude-plugin/plugin.json" <<'EOF'
{
  "name": "vault",
  "version": "1.0.0",
  "description": "Personal skills from Obsidian vault at ~/notes/brain/40-skills"
}
EOF

# Flat-symlink every vault skill into the plugin's skills/ dir
# Both custom/ and gathered/ contents end up siblings under skills/
for skill_dir in "$HOME/notes/brain/40-skills/custom"/*/ \
                 "$HOME/notes/brain/40-skills/gathered"/*/; do
  skill_name=$(basename "$skill_dir")
  link "${skill_dir%/}" "$PLUGIN_DIR/skills/$skill_name"
done

# Link the adapted CLAUDE.md (Claude Code reads this at session start)
link "$HOME_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Settings
link "$HOME_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Per-machine settings override (work vs personal)
# Mirrors opencode.local.json → work/personal pattern
if [[ "$CURR_HOST" == On-* ]]; then
  link "$HOME_DIR/claude/settings.work.json" "$HOME/.claude/settings.local.json"
else
  link "$HOME_DIR/claude/settings.personal.json" "$HOME/.claude/settings.local.json"
fi

# Agents and commands directories
link "$HOME_DIR/claude/agents" "$HOME/.claude/agents"
link "$HOME_DIR/claude/commands" "$HOME/.claude/commands"
