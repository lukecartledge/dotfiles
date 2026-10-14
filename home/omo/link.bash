# Link OmO Native configuration to ~/.omo
#
# Seed Native's unified config without overwriting runtime edits. MCP servers
# are selected per host to preserve the OpenCode work/personal boundary.

OMO_AGENT_DIR="$HOME/.omo/agent"
mkdir -p "$OMO_AGENT_DIR"

if [[ ! -e "$HOME/.omo/omo.jsonc" && ! -L "$HOME/.omo/omo.jsonc" ]]; then
  if [[ "$dry" == "1" ]]; then
    log "Would seed $HOME/.omo/omo.jsonc from dotfiles"
  else
    cp "$HOME_DIR/omo/config/omo.jsonc" "$HOME/.omo/omo.jsonc"
    success "Seeded OmO Native config"
  fi
else
  info "Preserving existing OmO Native config"
fi
link "$HOME_DIR/shared/agent-instructions-core.md" "$OMO_AGENT_DIR/AGENTS.md"

if [[ "$CURR_HOST" == On-* ]]; then
  link "$HOME_DIR/omo/config/mcp.work.json" "$OMO_AGENT_DIR/mcp.json"
else
  link "$HOME_DIR/omo/config/mcp.personal.json" "$OMO_AGENT_DIR/mcp.json"
fi

ORG_SKILLS="$HOME/.local/share/onrunning/dev-tooling-config/skills"
if [[ -d "$ORG_SKILLS" ]]; then
  link "$ORG_SKILLS" "$OMO_AGENT_DIR/skills"
else
  info "On dev-tooling skills not linked — clone onrunning/dev-tooling-config to $HOME/.local/share/onrunning"
fi
