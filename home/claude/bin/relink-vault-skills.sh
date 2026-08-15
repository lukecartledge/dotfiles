#!/usr/bin/env bash
# Relink all vault skills into the Claude Code vault plugin.
# Run this after adding, renaming or retiring a skill in ~/notes/brain/40-skills/.
# Idempotent — safe to run multiple times.
#
# Creates a symlink per skill AND prunes ones that no longer resolve. The prune
# half matters: OpenCode links the two skill folders wholesale, so retirements
# there are picked up for free, but Claude Code links each skill individually.
# Without pruning, retiring a skill leaves a dangling symlink behind, and a
# dangling entry breaks skill loading for the whole plugin.
set -euo pipefail

VAULT_SKILLS="${VAULT_SKILLS:-$HOME/notes/brain/40-skills}"
PLUGIN_DIR="${PLUGIN_DIR:-$HOME/.claude/skills/vault}"
DEST="$PLUGIN_DIR/skills"
mkdir -p "$DEST"

dry_run=0
[[ "${1:-}" == "--dry-run" ]] && dry_run=1

linked=0
pruned=0

# --- link: flat-symlink every current skill -------------------------------
# custom/ and gathered/ contents end up siblings under skills/
for skill_dir in "$VAULT_SKILLS/custom"/*/ "$VAULT_SKILLS/gathered"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "${skill_dir%/}")
  target="$DEST/$skill_name"
  if [[ $dry_run -eq 1 ]]; then
    [[ -L "$target" && "$(readlink "$target")" == "${skill_dir%/}" ]] || \
      echo "  would link   $skill_name"
  else
    ln -sfn "${skill_dir%/}" "$target"
  fi
  linked=$((linked + 1))
done

# --- prune: drop symlinks that no longer resolve --------------------------
# Only ever removes SYMLINKS, and only ones whose target is gone. A real file
# or directory placed here by hand is left alone rather than silently deleted.
shopt -s nullglob
for entry in "$DEST"/*; do
  [[ -L "$entry" ]] || continue          # never touch real files/dirs
  [[ -e "$entry" ]] && continue          # target still resolves — keep
  if [[ $dry_run -eq 1 ]]; then
    echo "  would prune  $(basename "$entry") -> $(readlink "$entry")"
  else
    rm -- "$entry"
  fi
  pruned=$((pruned + 1))
done
shopt -u nullglob

if [[ $dry_run -eq 1 ]]; then
  echo "Dry run: $linked skill(s) in the vault, $pruned dangling symlink(s) to prune."
else
  echo "Vault skill relink complete. $linked skill(s) linked, $pruned pruned, $(find "$DEST" -maxdepth 1 -mindepth 1 | wc -l | tr -d ' ') total."
fi
