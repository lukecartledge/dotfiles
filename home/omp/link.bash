# Link omp (oh-my-pi) configuration to ~/.omp/agent
#
# Individual files are linked rather than the whole directory so omp can keep
# its runtime state (sessions, agent.db, extensions/) alongside them.
# Mirrors the opencode setup: shared instructions, the same commands and
# agents, vault skills (via config.yml), and a per-host MCP overlay.

OMP_AGENT_DIR="$HOME/.omp/agent"
mkdir -p "$OMP_AGENT_DIR"

# Global settings (models, agent model pins, vault skill directories)
link "$HOME_DIR/omp/config/config.yml" "$OMP_AGENT_DIR/config.yml"

# Shared instructions; omp keeps only one user-level context file
link "$HOME_DIR/shared/agent-instructions-core.md" "$OMP_AGENT_DIR/AGENTS.md"

# ECC instructions opencode loads, as an always-apply sticky rule
link "$HOME_DIR/opencode/config/instructions/INSTRUCTIONS.md" "$OMP_AGENT_DIR/RULES.md"

# omp-specific notes appended to the default system prompt
link "$HOME_DIR/omp/config/APPEND_SYSTEM.md" "$OMP_AGENT_DIR/APPEND_SYSTEM.md"

# Slash commands shared with opencode
link "$HOME_DIR/opencode/config/commands" "$OMP_AGENT_DIR/commands"

# Task agents shared with Claude Code (models pinned in config.yml)
link "$HOME_DIR/claude/agents" "$OMP_AGENT_DIR/agents"

# MCP servers: shared list plus a per-host overlay. omp reads both
# mcp.json and .mcp.json from the agent dir.
link "$HOME_DIR/omp/config/mcp.json" "$OMP_AGENT_DIR/mcp.json"
if [[ "$CURR_HOST" == On-* ]]; then
  link "$HOME_DIR/omp/config/mcp.work.json" "$OMP_AGENT_DIR/.mcp.json"
else
  link "$HOME_DIR/omp/config/mcp.personal.json" "$OMP_AGENT_DIR/.mcp.json"
fi

if [[ ! -d "$HOME/notes/brain/40-skills" ]]; then
  # shellcheck disable=SC2088  # tilde in user-facing string is intentional
  fail "~/notes/brain not found — omp vault skills unavailable until it is cloned"
fi
