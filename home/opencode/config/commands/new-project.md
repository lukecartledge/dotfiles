Create a new project in the Obsidian vault and optionally scaffold OpenCode config in the current repo.

The project name is: $ARGUMENTS

## Step 1: Create the Obsidian project note

1. Create the folder `~/notes/brain/20-work/projects/$ARGUMENTS/`
2. Create `~/notes/brain/20-work/projects/$ARGUMENTS/$ARGUMENTS.md` with this frontmatter:

```yaml
---
type: project
name: $ARGUMENTS
created: {{date}}
status: active
tags: []
github-repo:
jira-project:
related-skills: []
opencode-agents-md: false
---
```

3. Add these sections to the file:

```markdown
## Goal

<!-- What does done look like? One or two sentences. -->

## Context

<!-- Background, constraints, dependencies, links to relevant notes or Confluence pages. -->

## Links

| Resource | URL |
|----------|-----|
| GitHub repo | |
| Jira board | |
| Confluence | |

## OpenCode setup

- [ ] AGENTS.md created
- [ ] opencode.json created
- [ ] Skills linked

## Decisions

<!-- Key technical or architectural decisions made during this project. Date them. -->

## Tasks

- [ ]

## Sessions

\```dataview
TABLE date, model, skills-used
FROM "opencode/sessions"
WHERE project = "$ARGUMENTS"
SORT date DESC
\```

## Notes
```

## Step 2: Detect project metadata

- Check the current working directory for a `.git` remote — if found, extract the GitHub repo URL and fill in the `github-repo` frontmatter field and the Links table.
- Ask the user for the Jira project key (e.g. "COP") if not provided as part of $ARGUMENTS. Fill in `jira-project` and the Jira board link (`https://onrunning.atlassian.net/jira/software/projects/<KEY>/board`).

## Step 3: Offer to scaffold per-repo OpenCode config

Ask the user: "Do you want me to create an AGENTS.md and opencode.json in the current repo for this project?"

If yes:

1. Create `AGENTS.md` in the repo root with:
   - A one-line project description header
   - A STRUCTURE section with key directories
   - A WHERE TO LOOK section mapping tasks to file locations
   - A Code Style & Conventions section noting any linter/formatter config present
   - Reference to relevant skills from `~/.config/opencode/skills/`

2. Create `opencode.json` in the repo root with:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "instructions": ["AGENTS.md"]
   }
   ```

3. Update the Obsidian project note: set `opencode-agents-md: true` and check off the OpenCode setup items.

## Step 4: Confirm

Tell the user:
- The Obsidian project note path
- Whether per-repo config was created
- Remind them to fill in the Goal and Context sections
