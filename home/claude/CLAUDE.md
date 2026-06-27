@~/.dotfiles/home/shared/agent-instructions-core.md

## Claude Code–specific

### Provider

Claude Code runs on **Anthropic claude.ai Pro** (luke@lukecartledge.com). Model aliases:
- Heavy reasoning: `opus`
- Balanced: `sonnet`
- Fast/cheap: `haiku`

Do NOT use `github-copilot/` prefixes — those are OpenCode-only.

### Filesystem paths

Claude Code config lives at `~/.dotfiles/home/claude/` and is symlinked into `~/.claude/` by the dotfiles `link.bash` script. When editing CLAUDE.md, edit the symlinked file.

Skills from the Obsidian vault are surfaced to Claude Code via the `vault` aggregator plugin at `~/.claude/skills/vault/skills/{skill-name}/`.

### Skill locations

Global skills: `~/.claude/skills/`
Custom skills: `~/notes/brain/40-skills/custom/` (symlinked into Claude via vault plugin)
Gathered skills: `~/notes/brain/40-skills/gathered/` (symlinked into Claude via vault plugin)

### Workflow commands

- `/user:tdd` — enforce TDD workflow with 80%+ coverage
- `/user:verify` — run verification loop to validate implementation
- `/user:new-skill` — scaffold a new skill in the Obsidian vault
- `/user:new-project` — create a new project in the Obsidian vault at ~/notes/brain/20-work/projects/ with optional per-repo config
- `/user:save-session` — save session summary to the Obsidian vault
- `/user:save-prompt` — save a reusable prompt to the Obsidian vault

### MCP tools available

- atlassian — Jira and Confluence
- contentful — CMS content management
- github — repo and PR management
- newrelic — observability and monitoring

### Superpowers

Superpowers plugin provides: brainstorming, TDD, systematic-debugging, writing-plans,
executing-plans, dispatching-parallel-agents, verification-before-completion, and more.
Install: `/plugin install superpowers@claude-plugins-official`
Invoke via `/superpowers:skill-name` or let them auto-trigger from description matching.
