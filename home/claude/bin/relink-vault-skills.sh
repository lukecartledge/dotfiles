#!/usr/bin/env bash
# Relink all vault skills into the Claude Code vault plugin.
# Run this after adding a new skill to ~/notes/brain/40-skills/.
# Idempotent — safe to run multiple times.
set -euo pipefail

PLUGIN_DIR="$HOME/.claude/skills/vault"
mkdir -p "$PLUGIN_DIR/skills"

# Flat-symlink every vault skill into the plugin's skills/ dir
# Both custom/ and gathered/ contents end up siblings under skills/
for skill_dir in "$HOME/notes/brain/40-skills/custom"/*/ \
                 "$HOME/notes/brain/40-skills/gathered"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "${skill_dir%/}")
  target="$PLUGIN_DIR/skills/$skill_name"
  ln -sfn "${skill_dir%/}" "$target"
done

echo "Vault skill relink complete. $(ls "$PLUGIN_DIR/skills" | wc -l) skills linked."
