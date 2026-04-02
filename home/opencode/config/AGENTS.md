## Identity

You are working inside a personal dev vault. Notes and skills are stored in Obsidian at ~/notes/dev.

## General rules

- Check for a relevant SKILL.md before starting any complex or repeatable task
- If a task produces a reusable pattern, flag it for promotion to a skill
- Save session outputs to ~/notes/dev-vault/opencode/sessions/ when asked
- Keep AGENTS.md files concise — instructions only, no explanations
- Always run verification after implementation using the verify command
- Follow TDD workflow for all new code — tests first, then implementation
- Apply security review checks before marking any task complete

## Workflow commands

- /user:tdd — enforce TDD workflow with 80%+ coverage
- /user:verify — run verification loop to validate implementation
- /user:new-skill — scaffold a new skill in the Obsidian vault
- /user:new-project — create a new project in the Obsidian vault with optional per-repo OpenCode config
- /user:save-session — save session summary to the Obsidian vault
- /user:save-prompt — save a reusable prompt to the Obsidian vault

## Skill locations

Global skills: ~/.config/opencode/skills/
Custom skills: ~/notes/dev/skills/custom/
Gathered skills: ~/notes/dev/skills/gathered/

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
