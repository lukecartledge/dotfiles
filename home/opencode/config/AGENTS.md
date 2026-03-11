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
- opslevel — service catalog
- newrelic — observability and monitoring
