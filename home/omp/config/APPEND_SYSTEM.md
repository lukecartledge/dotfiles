## omp-specific

- omp config lives at `~/.dotfiles/home/omp/config/` and is symlinked into `~/.omp/agent/` by the dotfiles `link.bash` script. When editing omp config, edit the symlinked file.
- `~/.omp/agent/AGENTS.md` is the shared `home/shared/agent-instructions-core.md`; `RULES.md` is opencode's `instructions/INSTRUCTIONS.md`.
- MCP servers: shared ones in `mcp.json`; host-specific ones in `.mcp.json` (`mcp.work.json` on On-* hosts, `mcp.personal.json` otherwise).
- Skills come from `~/notes/brain/40-skills/{custom,gathered}` via `skills.customDirectories`.
- Models run through GitHub Copilot (`/login github-copilot`). Tiers mirror opencode's `oh-my-openagent.json`.
