Scaffold a new skill in the Obsidian vault.

1. Create the folder ~/notes/dev/skills/custom/$ARGUMENTS/
2. Create ~/notes/dev/skills/custom/$ARGUMENTS/SKILL.md with this frontmatter:
---
name: $ARGUMENTS
description:
version: "1.0"
status: draft
source: custom
tags: []
created: {{date}}
updated: {{date}}
related-skills: []
---
3. Add these sections to the file:
   ## When to use
   ## Instructions
   ## Examples
   ## Notes
   ## Changelog
   - {{date}} — created
4. Remind me to fill in the description field before marking status as tested
