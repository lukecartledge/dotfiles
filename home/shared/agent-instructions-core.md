## Identity

Personal dev environment. Notes and skills are stored in Obsidian at ~/notes/brain.

## Filesystem topology

All configuration and knowledge lives in two managed locations:

- **Dotfiles** (`~/.dotfiles`) — Source of truth for all machine config. Synced via GitHub (`lukecartledge/dotfiles`). Config is symlinked into the appropriate tool directory by the dotfiles `link.bash` script. When editing config files, edit the symlinked file (changes propagate to dotfiles automatically).
- **Knowledge base** (`~/notes/brain`) — Obsidian vault with projects, sessions, skills, and notes. Synced separately.
  - Sessions: `~/notes/brain/20-work/sessions/`
  - Skills (custom): `~/notes/brain/40-skills/custom/`
  - Skills (gathered): `~/notes/brain/40-skills/gathered/`

## Projects

All projects are tracked in ~/notes/brain/20-work/projects/. Key projects:
- lukecartledge-website — personal portfolio site
- dtc-platform — DTC platform work
- shopify-apps — Shopify app development
- dotfiles — personal dotfiles (`~/.dotfiles`, GitHub: lukecartledge/dotfiles)
- infrastructure — infra configs

### On AG work repos (~/code/onag/)

These repos use the COP Jira project. Branch names and PR titles **must**
start with the Jira ticket key:

- Branch format: `COP-XXX/<short-slug>`
- PR title format: `COP-XXX: <imperative description>`
- A GitHub Action validates the prefix and auto-links the Jira ticket.
- Do **not** use Conventional Commit prefixes (`feat(…)`, `chore(…)`) in
  branch names or PR titles — those are for commit messages only.

### Personal repos

No Jira ticket prefix required. Use descriptive branch names freely.

## Coding behaviour

These rules apply to every code change. Bias toward caution over speed — for trivial one-liners, use judgment.

### Think before coding

- State assumptions explicitly. If uncertain, ask before writing code.
- If multiple interpretations exist, present them — do not pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name the confusion. Ask.

### Verify before investing

- Run the cheapest possible test that would disprove your assumption before building on it.
- At integration boundaries: confirm the API/system actually behaves as docs claim. One probe call before full implementation.
- At delivery boundaries: verify arrival, not just dispatch. Upstream 2xx does not mean downstream received.
- At environment level: confirm ambient state (tunnel alive, deps fresh, CI convention matched) before debugging code.
- If something "should work" but doesn't after 3 attempts, stop and isolate — you're likely testing the wrong layer.

### Simplicity first

- Write the minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite. Ask: "Would a senior engineer call this overcomplicated?"

### Surgical changes

- Touch only what the task requires. Do not "improve" adjacent code, comments, or formatting.
- Do not refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you spot unrelated dead code, mention it — do not delete it.
- Remove imports/variables/functions that YOUR changes made unused. Do not remove pre-existing dead code unless asked.
- **Every changed line must trace directly to the user's request.**

### Goal-driven execution

- Transform tasks into verifiable goals before starting:
  - "Add validation" → "Write tests for invalid inputs, then make them pass"
  - "Fix the bug" → "Write a test that reproduces it, then make it pass"
  - "Refactor X" → "Ensure tests pass before and after"
- For multi-step tasks, state a brief plan with verification checkpoints:
  ```
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
  ```
- Strong success criteria enable autonomous looping. Weak criteria ("make it work") require clarification — ask for it.

## Git discipline

All commits must be **atomic**. Load the `git-atomic-commits` skill whenever committing.

### Core test — apply before every commit

1. Does this do exactly one thing?
2. Does the build/tests pass at this exact commit?
3. Can `git revert <sha>` undo it cleanly?
4. Can the message be written without "and" or "also"?

If any answer is **no**, split the commit.

### Commit messages

- Use Conventional Commits format: `type(scope): imperative description`
- Subject: imperative mood, 72 chars max, no period, capitalise first word after type prefix.
- Body (if needed): explain **what** and **why**, not how.
- Apply the "and" test — if you can't write the subject without "and", the commit needs splitting.

### Staging

- Use `git add -p` to stage specific hunks when a working tree contains multiple logical changes.
- Run `git diff --staged` before every commit to confirm scope.
- Never commit unrelated changes together.

### PR branch work

- When addressing PR review feedback or working on an open PR branch, commit and push after verification passes — don't wait for an explicit push request.
- The intent "address PR comments" implies shipping the result.

## General rules

- Check for a relevant SKILL.md before starting any complex or repeatable task.
- If a task produces a reusable pattern, flag it for promotion to a skill.
- Save session outputs to ~/notes/brain/20-work/sessions/ when asked.
- Keep agent instruction files concise — instructions only, no explanations.
- Always run verification after implementation.
- Follow TDD workflow for all new code — tests first, then implementation.
- Apply security review checks before marking any task complete.
