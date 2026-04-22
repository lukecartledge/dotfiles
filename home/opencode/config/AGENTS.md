## Identity

You are working inside a personal dev vault. Notes and skills are stored in Obsidian at ~/notes/brain.

## Filesystem topology

All configuration and knowledge lives in two managed locations:

- **Dotfiles** (`~/.dotfiles`) — Source of truth for all machine config. Synced via GitHub (`lukecartledge/dotfiles`). OpenCode config lives at `~/.dotfiles/home/opencode/config/` and is symlinked into `~/.config/opencode/` by the dotfiles `link.bash` script. When editing opencode config, always edit the symlinked file (changes propagate to dotfiles automatically).
- **Knowledge base** (`~/notes/brain`) — Obsidian vault with projects, sessions, skills, and notes. Synced separately.
  - Sessions: `~/notes/brain/20-work/sessions/`
  - Skills (custom): `~/notes/brain/40-skills/custom/` → symlinked to `~/.config/opencode/skills/custom`
  - Skills (gathered): `~/notes/brain/40-skills/gathered/` → symlinked to `~/.config/opencode/skills/gathered`
- **Machine-specific overrides** use `opencode.local.json` (symlinked per-host from dotfiles: `opencode.work.json` on On-* hosts, `opencode.personal.json` otherwise).

## Model preferences

- **Stay on claude-opus-4.6** — do not upgrade to 4.7 unless explicitly asked. The OMO config (`oh-my-openagent.json`) pins all Claude agents to 4.6.
- On GitHub Copilot: Claude models support `low`, `medium`, `high` variants only (no `max` or `xhigh`). GPT models support `low`, `medium`, `high`, `xhigh`.
- `claude-opus-4.7` on Copilot only supports `medium` — avoid it.

## Projects

All projects are tracked in ~/notes/brain/20-work/projects/. Key projects:
- lukecartledge-website — personal portfolio site
- dtc-platform — DTC platform work
- shopify-apps — Shopify app development
- dotfiles — personal dotfiles (`~/.dotfiles`, GitHub: lukecartledge/dotfiles)
- infrastructure — infra configs

### On AG work repos (~/code/onag/)

These repos use the COP Jira project. Branch names and PR titles **must**
start with the Jira ticket key:

- Branch format: `COP-XXX/<short-slug>`
- PR title format: `COP-XXX: <imperative description>`
- A GitHub Action validates the prefix and auto-links the Jira ticket.
- Do **not** use Conventional Commit prefixes (`feat(…)`, `chore(…)`) in
  branch names or PR titles — those are for commit messages only.

### Personal repos

No Jira ticket prefix required. Use descriptive branch names freely.

## General rules

- Check for a relevant SKILL.md before starting any complex or repeatable task
- If a task produces a reusable pattern, flag it for promotion to a skill
- Save session outputs to ~/notes/brain/20-work/sessions/ when asked
- Keep AGENTS.md files concise — instructions only, no explanations
- Always run verification after implementation using the verify command
- Follow TDD workflow for all new code — tests first, then implementation
- Apply security review checks before marking any task complete

## Workflow commands

- /user:tdd — enforce TDD workflow with 80%+ coverage
- /user:verify — run verification loop to validate implementation
- /user:new-skill — scaffold a new skill in the Obsidian vault
- /user:new-project — create a new project in the Obsidian vault at ~/notes/brain/20-work/projects/ with optional per-repo OpenCode config
- /user:save-session — save session summary to the Obsidian vault
- /user:save-prompt — save a reusable prompt to the Obsidian vault

## Skill locations

Global skills: ~/.config/opencode/skills/
Custom skills: ~/notes/brain/40-skills/custom/
Gathered skills: ~/notes/brain/40-skills/gathered/

## MCP tools available

- atlassian — Jira and Confluence
- contentful — CMS content management
- github — repo and PR management
- newrelic — observability and monitoring
- context-mode — context window optimization and session continuity

## context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

### BLOCKED commands — do NOT attempt these

- **curl / wget** — intercepted and blocked by context-mode plugin. Use `context-mode_ctx_fetch_and_index(url, source)` or `context-mode_ctx_execute(language: "javascript", code: "const r = await fetch(...)")` instead.
- **Inline HTTP** — `fetch('http`, `requests.get(`, etc. blocked in shell. Use `context-mode_ctx_execute(language, code)` instead.
- **Direct web fetching** — Use `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)`.

### REDIRECTED tools — use sandbox equivalents

- **Shell (>20 lines output)** — Shell is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands. For everything else use `context-mode_ctx_batch_execute` or `context-mode_ctx_execute`.
- **File reading (for analysis)** — If reading to **edit**, reading is correct. If reading to **analyze/summarize**, use `context-mode_ctx_execute_file(path, language, code)` instead.
- **grep / search (large results)** — Use `context-mode_ctx_execute(language: "shell", code: "grep ...")` for large search results.

### Tool selection hierarchy

1. **GATHER**: `context-mode_ctx_batch_execute(commands, queries)` — Primary tool. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `context-mode_ctx_search(queries)` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `context-mode_ctx_execute(language, code)` | `context-mode_ctx_execute_file(path, language, code)` — Sandbox execution.
4. **WEB**: `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)`.
5. **INDEX**: `context-mode_ctx_index(content, source)` — Store content in FTS5 knowledge base.
