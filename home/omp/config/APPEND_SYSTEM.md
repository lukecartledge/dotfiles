## omp-specific

- omp config lives at `~/.dotfiles/home/omp/config/` and is symlinked into `~/.omp/agent/` by the dotfiles `link.bash` script. When editing omp config, edit the symlinked file.
- `~/.omp/agent/AGENTS.md` is the shared `home/shared/agent-instructions-core.md`; `RULES.md` is opencode's `instructions/INSTRUCTIONS.md`.
- MCP servers: shared ones in `mcp.json`; host-specific ones in `.mcp.json` (`mcp.work.json` on On-* hosts, `mcp.personal.json` otherwise).
- Skills come from `~/.local/share/onrunning/dev-tooling-config/skills` and `~/notes/brain/40-skills/{custom,gathered}` via `skills.customDirectories`; organisation copies take precedence on name conflicts.
- Models run through GitHub Copilot (`/login github-copilot`). Model roles are configured in `~/.omp/agent/config.yml`; OMO's separate routing lives in `~/.omo/omo.jsonc`.
