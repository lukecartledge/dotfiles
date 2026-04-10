Scaffold a new skill in the Obsidian vault.

The skill name is: $ARGUMENTS

## Step 1: Create the skill folder and file

1. Create the folder `~/notes/brain/40-skills/custom/$ARGUMENTS/`
2. Create `~/notes/brain/40-skills/custom/$ARGUMENTS/SKILL.md` with this frontmatter:

```yaml
---
name: $ARGUMENTS
description: >
  
type: skill
source: custom
status: draft
version: "1.0"
tags: []
created: {{date}}
related-skills: []
---
```

3. Add these sections to the file:

```markdown
## Purpose

<!-- What does this skill do and why does it exist? One paragraph. -->

## When to use me

<!-- Specific situations or trigger phrases that should prompt loading this skill. Use a bullet list. -->

## Step-by-step procedure

<!-- Detailed instructions for the AI agent to follow. Number each step. -->

## Rules and guardrails

<!-- Hard constraints: what the agent must and must not do while executing this skill. -->

## Example interaction

<!-- A realistic example showing input/output or a conversation snippet. -->

## Notes

<!-- Edge cases, gotchas, or things to watch out for. -->

## Changelog

- {{date}} — created
```

## Step 2: If session context is available

- If this command is run during or after a session, check the conversation for relevant patterns, prompts, or workflows that motivated this skill.
- Pre-fill the Purpose and Step-by-step procedure sections with content extracted from the session.
- Pre-fill tags based on session context.

## Step 3: Symlink check

- Check if the symlink `~/.config/opencode/skills/custom` → `~/notes/brain/40-skills/custom` exists.
- If not, warn the user and suggest running:
  ```sh
  ln -sfn ~/notes/brain/40-skills/custom ~/.config/opencode/skills/custom
  ```

## Step 4: Confirm

Tell the user:
- The file path created
- Remind them to fill in the `description` field — OpenCode reads this to decide when to load the skill
- Remind them to set `status: tested` only after validating the skill in a real session
