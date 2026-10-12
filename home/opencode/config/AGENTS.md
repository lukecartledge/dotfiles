# OpenCode-specific guidance

Shared rules live in `~/.dotfiles/home/shared/agent-instructions-core.md`, linked
as `~/.config/opencode/AGENTS.md`. This supplement is linked as
`~/.config/opencode/APPEND_SYSTEM.md`; do not duplicate shared rules here.

## Configuration

- OpenCode config lives in `~/.dotfiles/home/opencode/config/`, linked into `~/.config/opencode/` by `home/opencode/link.bash`.
- Machine-specific overrides use `opencode.local.json`, linked from `opencode.work.json` on On-* hosts and `opencode.personal.json` otherwise.
- OmO Native routing lives in the regular runtime file `~/.omo/omo.jsonc`, initially seeded from `~/.dotfiles/home/omo/config/omo.jsonc`. It is not automatically synced back during the Native evaluation. The `[native]` block configures standalone OmO; legacy `[opencode]` settings and `oh-my-openagent.json` do not configure OpenCode V2, whose incompatible OMO plugin is disabled.
- Terminal preferences and keybindings live in `~/.config/opencode/cli.json`.

## Models

- Use GitHub Copilot. Preserve the configured model choices unless the user asks to change them.
- The configured session/default heavy model is `gpt-6-sol`; lightweight lanes use `gpt-6-luna`.
- Avoid `claude-sonnet-5` (poor results in practice).
- Copilot bills per token at API rates (AI credits, since Jun 2026); choose models on $/MTok, not request multipliers.
- Query served models live. Check provider-specific reasoning values in `~/.cache/opencode/models.json` before setting a variant.
- Check the installed OMO version and its current routing rules rather than applying legacy Sisyphus/GPT gate assumptions.

## Skills and workflow commands

- Global skills: `~/.config/opencode/skills/`.
- Vault skills: `~/notes/brain/40-skills/{custom,gathered}/`, symlinked into the global skills directory.
- Organisation skills: `https://dev-tooling.on.com/skills/`.
- `/user:tdd` — enforce TDD workflow with 80%+ coverage.
- `/user:verify` — run the verification loop.
- `/user:new-skill` — scaffold a vault skill.
- `/user:new-project` — create a vault project under its work/personal root.
- `/user:save-session` — save the session summary to the vault.
- `/user:save-prompt` — save a reusable prompt to the vault.

## MCPs

- Organisation MCP definitions come from `https://dev-tooling.on.com/.well-known/opencode`.
- Inspect live connection status before relying on a server; a configured server may be disabled or require sign-in.
- Available integrations include Atlassian, Contentful, GitHub, New Relic, incident.io, and context-mode; enablement is controlled by config.

## context-mode routing

Use context-mode when its tools are available to avoid flooding the context window.

- Do not use shell `curl`/`wget` or inline HTTP requests. Use context-mode's fetch/index or sandbox execution tools.
- For large command output, prefer `ctx_batch_execute` or `ctx_execute`; use `ctx_search` for follow-up questions.
- Read files normally when editing. For analysis/summarisation, prefer `ctx_execute_file`.
- Route large grep/search results through sandbox execution.
- Prefer fetch-and-index then search for web content.
- If context-mode tools are absent, report the gap and use available native tools with bounded output. Never call invented or unavailable tool names.
