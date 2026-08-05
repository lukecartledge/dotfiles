---
description: List registered projects in the Obsidian vault
---

# Projects Command

List projects tracked in the Obsidian vault: $ARGUMENTS

## Your Task

Show all projects registered in the knowledge base.

Run:

```bash
ls ~/notes/brain/20-work/projects/
ls ~/notes/brain/10-personal/projects/
```

For each project directory found, read the project note (`<name>/<name>.md`) and display:
- Project name
- Status (from frontmatter)
- GitHub repo (if set)
- Jira project (if set)
- Creation date

## Output Format

```
Projects
========

Active:
- project-name (created: YYYY-MM-DD) [github-repo] [jira-project]
- ...

Archived/Inactive:
- project-name (created: YYYY-MM-DD)
- ...
```

## Vault Location

Projects live at: `~/notes/brain/20-work/projects/` (work) and `~/notes/brain/10-personal/projects/` (personal)

Each project has a note at: `<root>/<name>/<name>.md`, where `<root>` is whichever of the two roots it sits in

To create a new project, use `/new-project <name>`.
