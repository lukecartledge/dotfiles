Save a reusable prompt to the Obsidian vault.

The prompt name/topic is: $ARGUMENTS

## Step 1: Extract the prompt from the current session

Review the full conversation and identify the specific prompt the user wants to save (referenced by $ARGUMENTS or the most recent notable prompt).

Extract the complete prompt text, preserving all formatting, variables, and structure. Identify the prompt type:
- `system-prompt` — instructions for agent behavior or identity
- `task-prompt` — structured task instructions for a specific goal
- `code-generation` — prompts that generate code
- `debugging` — prompts for troubleshooting or analysis
- `review` — prompts for code review or quality checking
- `research` — prompts for exploration or information gathering
- `template` — reusable prompt structure with placeholders

## Step 2: Determine the source session

- Check if a session file was recently saved to `~/notes/brain/20-work/sessions/`.
- If found, record the session as a wiki-link: `"[[2026-03-17-my-task]]"` (without `.md` extension).
- If no recent session exists, leave `source-session` as an empty string `""`.

## Step 3: Gather metadata

Extract relevant tags from the prompt content:
- Include technologies mentioned (e.g., `react`, `typescript`, `solana`)
- Include tools referenced (e.g., `jira`, `github-pr`, `new-relic`)
- Include domains or domains (e.g., `security`, `testing`, `documentation`)
- Use lowercase, hyphenated tags only

Determine the prompt category based on type and content:
- `agent-instruction` — for system prompts or agent guardrails
- `code-generation` — for generating code or configuration
- `debugging` — for troubleshooting or analysis
- `workflow` — for multi-step procedures or repeatable patterns
- `review` — for QA, security, or quality checks
- `research` — for exploration or information gathering

## Step 4: Create the prompt file

Create a new file at `~/notes/brain/20-work/prompts/$ARGUMENTS.md` (use kebab-case for the filename; transform $ARGUMENTS if needed).

Use this frontmatter:

```yaml
---
type: prompt
name: $ARGUMENTS
created: {{date}}
tags: [<detected-tags>]
category: <detected-category>
source-session: "<detected-session-as-wiki-link-or-empty>"
status: untested
---
```

**IMPORTANT — Wiki-link rules for backlinks:**
- `source-session:` MUST be a wiki-link if a source session exists: `"[[2026-03-17-my-task]]"` (without `.md`). This creates a backlink from the session to this prompt.
- If no source session, use `""`.
- The `## Related` section at the bottom MUST contain wiki-links to the source session, project, and any related knowledge notes.

Write these sections:

```markdown
## Purpose

<!-- When and why to use this prompt. One or two sentences. -->

## Prompt

<!-- The full prompt text exactly as it should be reused. -->

## Variables

<!-- Placeholders in the prompt that need to be filled in per-use. Use a table: | Variable | Description | Example | -->

## Example

<!-- A concrete example showing the prompt filled in with real values and the expected output or behavior. -->

## Notes

<!-- Edge cases, model-specific behavior, or tips for best results. -->

## Related

<!-- Wiki-links to related sessions, projects, knowledge notes, or other prompts. -->
- Source session: [[<source-session-name>]]
- Project: [[<project-name>]]
- Knowledge: 
```

## Step 5: Confirm

Tell the user:
- The file path created
- The detected source session (if any)
- Remind them to test the prompt and update `status: tested` once validated
- If the prompt came from a session, remind them to set `prompts-extracted: true` on the session file at the end of their work
