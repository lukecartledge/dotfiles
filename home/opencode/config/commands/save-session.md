Save this session to the Obsidian vault.

The session topic is: $ARGUMENTS

## Step 1: Determine the project name

- Check the current working directory for a git remote. Extract the repo name (e.g. `onrunning/shopify-promotion-extensions` → `shopify-promotion-extensions`).
- Check if a project note exists at `~/notes/dev/projects/<repo-name>/`. If it does, use that as the project name.
- If no git remote or no matching project note, ask the user for the project name.

## Step 2: Determine the model

- Use the model you are currently running as (check your system prompt or identity).

## Step 3: Gather session content

Review the full conversation and extract:

1. **Goal** — What the user was trying to achieve.
2. **Summary** — What actually happened: key decisions, changes made, PRs opened, tickets updated. Include links to PRs, Jira tickets, or other artifacts.
3. **What worked** — Specific techniques, tools, prompts, or approaches that were effective. Be concrete enough that they could be repeated.
4. **What didn't work** — Friction points, dead ends, tool limitations, things that wasted time.
5. **Prompts worth keeping** — Reusable prompts or prompt patterns that produced good results. Include the actual prompt text or structure. These are candidates for promotion to `~/notes/dev/opencode/prompts/`.
6. **Patterns worth turning into a skill** — Repeatable workflows that emerged naturally during the session. These are candidates for promotion to `~/notes/dev/skills/custom/`.
7. **Follow-up tasks** — Concrete next steps as checklist items.

## Step 4: Determine skills used

- Review the conversation for any skills that were loaded (via `/user:tdd`, `/user:verify`, or explicit skill loading).
- List them in the `skills-used` array.

## Step 5: Determine tags

- Extract relevant tags from the session content. Use lowercase, hyphenated tags.
- Include: technologies used, tools used (e.g. `new-relic`, `jira`, `github-pr`), domains touched (e.g. `alerting`, `sdk-upgrade`).

## Step 6: Create the session file

Create a new file at `~/notes/dev/opencode/sessions/{{year}}/{{month}}/{{date}}-$ARGUMENTS.md` with this content (create the year/month directories if they don't exist):

```yaml
---
type: session
date: {{date}}
project: <detected-project-name>
model: <current-model>
skills-used: [<detected-skills>]
tags: [<detected-tags>]
prompts-extracted: false
status: unprocessed
---
```

Then write each section:

```markdown
## Goal

<extracted-goal>

## Summary

<extracted-summary>

## What worked

<extracted-what-worked>

## What didn't work

<extracted-what-didnt-work>

## Prompts worth keeping

<extracted-prompts>

## Patterns worth turning into a skill

<extracted-patterns>

## Follow-up tasks

- [ ] <task-1>
- [ ] <task-2>
```

## Step 7: Confirm

Tell the user:
- The file path created
- The detected project name
- How many prompts and patterns were flagged for promotion
- Remind them to review and promote any prompts to `~/notes/dev/opencode/prompts/` via `/save-prompt`
