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
grep -rl --include='*.md' '^type: project' ~/notes/brain/10-personal/
```

Work projects are one flat root, so `ls` is enough. Personal projects are filed by area
and may be a bare note rather than a folder, so match on frontmatter instead.

For each project found, read the project note (`<name>/<name>.md`, or the bare note
itself) and display:
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

Projects live at: `~/notes/brain/20-work/projects/` (work) and `~/notes/brain/10-personal/<area>/` (personal)

Work projects have a note at `20-work/projects/<name>/<name>.md`. Personal projects sit
under their area — either `10-personal/<area>/<name>/<name>.md` or, when there are no
supporting files, a bare `10-personal/<area>/<name>.md`

To create a new project, use `/new-project <name>`.
