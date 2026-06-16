---
type: runbook
name: New Laptop Migration Runbook
parent-project: dotfiles
created: 2026-06-14
status: active
tags:
  - dotfiles
  - migration
  - macos
  - bootstrap
  - new-laptop
---

# New-Laptop Migration Runbook

> Living document. Audit, plan, and operational runbook for setting up a new
> macOS machine from these dotfiles. Intentionally over-explicit so future-me
> doesn't have to re-investigate.
>
> **Last audit:** 2026-06-14 (5 parallel agents, full repo + live-machine
> coverage check).
> **Next migration:** new On work MacBook (TBD arrival).

---

## Table of contents

1. [TL;DR](#tldr)
2. [Audit findings](#audit-findings)
3. [Repo changes plan](#repo-changes-plan)
4. [Pre-wipe checklist (do on the OLD laptop)](#pre-wipe-checklist-do-on-the-old-laptop)
5. [New-laptop Day-1 procedure](#new-laptop-day-1-procedure)
6. [Post-bootstrap verification](#post-bootstrap-verification)
7. [Reusing this runbook for future migrations](#reusing-this-runbook-for-future-migrations)
8. [Reference: legacy `git/` directory cleanup](#reference-legacy-git-directory-cleanup)

---

## TL;DR

The repo is structurally solid (BATS tests, ShellCheck, idempotent symlinks,
per-host configs) but the audit surfaced **10 silent-failure modes** on a
fresh macOS install. Two batches of fixes were applied:

- **Batch A** (pre-wipe minimum): track 4 untracked-but-essential files so
  nothing important lives only on the old laptop.
- **Batch B** (bootstrap reliability): make `script/bootstrap` actually take
  a fresh macOS install all the way to a working dev environment without
  silent partial-failures.

Two items are deliberately **deferred** to new-laptop day:

- The new laptop's `hosts/<hostname>.bash` (we don't know the hostname yet).
- Cleanup of the legacy `git/` directory (would break the current machine's
  git identity until `git/install.bash` re-runs).

Use the [pre-wipe checklist](#pre-wipe-checklist-do-on-the-old-laptop)
**before** wiping the old machine. Use the
[new-laptop Day-1 procedure](#new-laptop-day-1-procedure) on the new machine.

---

## Audit findings

Reproducible by running 5 parallel agents over the repo + live machine. Kept
verbatim here so the rationale for each fix is auditable.

### Critical — would cause silent failures on a fresh laptop

| # | Issue | Impact | Fixed in |
|---|---|---|---|
| C1 | `~/.p10k.zsh` tracked in `home/zsh/p10k.zsh` but never linked. Live machine has no `~/.p10k.zsh` — prompt runs on p10k defaults. | Wrong/default prompt on every machine after bootstrap. | Batch A |
| C2 | `home/opencode/link.bash` symlinks `~/.config/opencode/skills/{custom,gathered}` from `~/notes/brain/40-skills/...`, but bootstrap never clones the brain vault. `link()` prints `FAIL` and `return 1`s without aborting. | OpenCode launches with **zero skills** and no error in the bootstrap output. | Batch B |
| C3 | No host config for the new laptop's hostname. | `script/bootstrap` interactively offers a minimal 7-package default missing `smb`, `ghostty`, `opencode`, etc. | **Deferred** (do on new laptop) |
| C4 | `oh-my-zsh` sourced by `zshrc` but never installed by bootstrap. | First shell login fails: `source: no such file: ~/.oh-my-zsh/oh-my-zsh.sh`. | Batch B |
| C5 | `zsh-autosuggestions` and `zsh-syntax-highlighting` listed as plugins, neither installed. | Visual shell features silently absent. | Batch B |
| C6 | `mise install` never called by bootstrap. | Node 22, Ruby, Python, Rust, Bun absent — anything depending on them (incl. opencode npm plugins) fails. | Batch B |
| C7 | `~/.localrc` has no `.example` template. Sourced by zshrc; contains MCP tokens + `OPENCODE_CONFIG`. | Without it, opencode per-host overlay silently doesn't load and MCPs that need tokens silently fail. No source of truth for what tokens are needed. | Batch A |
| C8 | No `gh auth login` step. `gitconfig` hardcodes `gh auth git-credential` as credential helper. | All HTTPS GitHub git operations fail or prompt. | Documented in Day-1 procedure |
| C9 | No SSH key generation. `git/install.bash` silently skips signing if key absent. | No `signingkey` in `.gitconfig.local`, no `~/.ssh/allowed_signers`, `git log --show-signature` reports "No signature". | Batch B (added `home/ssh/install.bash`) |
| C10 | No Rosetta 2 install on Apple Silicon before `brew bundle`. | Some x86 bottles/casks fail mid-bundle. | Batch B |

### High-value untracked configs (data-loss risk if wiped without backup)

Found by inventorying `home/` packages vs. live `~/`, `~/.config/`,
`~/Library/Application Support/`. The top three are now tracked; the rest
are documented in the [pre-wipe checklist](#pre-wipe-checklist-do-on-the-old-laptop).

| Priority | Path | Why it matters | Status |
|---|---|---|---|
| P0 | `~/.localrc` | All API tokens + `OPENCODE_CONFIG`. Re-issuing tokens manually = an hour of dashboard-hunting. | `localrc.example` tracked (Batch A); secrets stay in 1Password |
| P0 | `~/.p10k.zsh` | Already in dotfiles, just needs the symlink. | Linked (Batch A) |
| P0 | `~/.zprofile` | Contains `eval $(brew shellenv)` + pipx PATH. Without it on a new shell, `brew` doesn't resolve. | Tracked (Batch A) |
| P1 | Alfred preferences | Workflows are gold. Alfred has built-in sync — point at dotfiles or Dropbox. | Manual (pre-wipe checklist) |
| P1 | `~/.docker/config.json` | Sets `currentContext=colima`. | Manual (pre-wipe checklist) |
| P1 | `~/.colima/default/colima.yaml` | Tuned VM (2 CPU, 100GB disk). | Manual (pre-wipe checklist) |
| P1 | `~/.gnupg/common.conf` | One-line `use-keyboxd`. | Manual (pre-wipe checklist) |
| P1 | `~/.ssh/allowed_signers` | Required for `git log --show-signature`. | Tracked as reference (Batch A); auto-regenerated by `git/install.bash` |
| P1 | VSCode `settings.json`, `keybindings.json`, extensions | 200+ lines, 88 extensions, none tracked. | Manual (pre-wipe checklist) |
| P2 | `~/.claude/rules/` | Claude Code project rules. | Manual (pre-wipe checklist) |
| P2 | Bartender, Rectangle Pro layouts | Painful to recreate. | Manual (pre-wipe checklist) |

### Cruft / legacy state on the current machine

- **`~/.gitconfig.local` is an orphan symlink** pointing to
  `~/.dotfiles/git/gitconfig.local.symlink` — the **pre-refactor** path. The
  old `git/` directory still exists in the repo from the 2022 holman fork.
  The new `home/git/install.bash` interactively creates the file fresh on a
  new machine. Cleanup procedure documented in
  [Reference: legacy git/ directory cleanup](#reference-legacy-git-directory-cleanup);
  not auto-applied.
- Three backup files in `~/.config/opencode/` (`opencode.json.backup.*`,
  `.bak`, `package-lock.json`) — runtime clutter, not declared anywhere.
  Manually clean if desired.

### Modern best-practice gaps (selectively adopted in Batch B)

| Gap | Adopted? | Rationale |
|---|---|---|
| Curl one-liner bootstrap | No | Working bootstrap; marginal win for single-developer repo. |
| Touch ID for sudo | **Yes** (Batch B) | 5–10 fewer password prompts during long `brew bundle`. |
| Firewall enable | **Yes** (Batch B) | Off by default on stock macOS; trivial. |
| Computer name set via `scutil` | Existing (`macos/set-hostname.sh`) | Already covered. |
| TCC permissions reminder at bootstrap end | **Yes** (Batch B) | Screen Recording / Accessibility / Full Disk Access can't be scripted. |
| `bin/check-baseline` health-check script | **Yes** (Batch B) | Best way to verify the new laptop in 5 seconds. |
| 1Password SSH agent + `op-ssh-sign` for git signing | No (future) | Big rewire of identity. Worth doing later, not blocking new laptop. |
| `bin/with-ai-env` (`op run --env-file`) | No (future) | Tokens in 1Password instead of `~/.localrc`. Same; later. |
| chezmoi / Nix migration | No | Migration cost > value for single-machine setup. |

---

## Repo changes plan

Two batches of changes land in this repo. Each item lists files touched,
intent, and verification.

### Batch A — pre-wipe minimum

**Goal:** ensure nothing essential lives only on the old laptop. Four items;
all idempotent; safe to run on the current machine.

- [x] **Track `~/.p10k.zsh`** — add symlink declaration in
      `home/zsh/link.bash` (file `home/zsh/p10k.zsh` already exists).
- [x] **Track `~/.zprofile`** — copy live `~/.zprofile` to
      `home/zsh/zprofile`, add `link_home` declaration. The file contains
      Apple Silicon `brew shellenv` + pipx PATH; no secrets.
- [x] **Create `home/system/localrc.example`** — committed template listing
      every env var name (no values). Real `~/.localrc` stays gitignored
      via existing `*.local*` pattern. Documented in 1Password retrieval
      path.
- [x] **Track `~/.ssh/allowed_signers`** — committed to `home/ssh/allowed_signers`
      as a backup/reference. **Not symlinked** — `home/git/install.bash`
      auto-regenerates the live file from `git config user.email` +
      `~/.ssh/id_ed25519.pub` on each new machine, and a symlink would
      block that regeneration with the wrong email on a work laptop.

### Batch B — bootstrap reliability

**Goal:** `script/bootstrap` on a fresh macOS install should take you to a
working dev environment without silent partial-failures.

- [x] **Brewfile additions** — `ghostty` cask. Closes the
      "ghostty-not-installed" gap surfaced during planning. (Note:
      `zsh-autosuggestions`/`zsh-syntax-highlighting` brews were
      considered but oh-my-zsh expects them at `$ZSH_CUSTOM/plugins/<name>/`,
      not `/opt/homebrew/share/`, so they are cloned from
      `home/zsh/install.bash` instead. Closes C5.)
- [x] **`home/zsh/install.bash`** — unattended oh-my-zsh install +
      clone `powerlevel10k`, `zsh-autosuggestions`, and
      `zsh-syntax-highlighting` into `$ZSH_CUSTOM`. Closes C4 and C5.
- [x] **`home/mise/install.bash`** — run `mise install` after the config
      symlink lands. Closes C6.
- [x] **`home/ssh/install.bash`** — generate `id_ed25519` if no key present;
      add to keychain via `ssh-add --apple-use-keychain`. Closes C9.
- [x] **`home/opencode/link.bash` brain guard** — skip the
      `~/notes/brain/40-skills/{custom,gathered}` symlinks with an
      actionable warning if the vault is absent. Closes C2.
- [x] **`script/bootstrap` Rosetta 2 + Xcode CLT** — install Rosetta on
      Apple Silicon and explicitly invoke `xcode-select --install` with
      a wait loop before installing Homebrew. Closes C10.
- [x] **`script/bootstrap` Touch ID + Firewall** — enable `pam_tid` for sudo
      via `/etc/pam.d/sudo_local`, enable application firewall.
- [x] **`script/bootstrap` TCC reminder** — print a manual-steps checklist
      at the end of bootstrap (Screen Recording, Accessibility, Full Disk
      Access).
- [x] **`bin/check-baseline`** — health-check script that verifies brew,
      mise, signing key, firewall, Touch-ID-for-sudo, all critical
      symlinks resolve, and `~/notes/brain` is present.
- [x] **`home/ssh/config` cleanup** — collapse the two stale absolute-path
      `Include` entries into a single `Include ~/.colima/ssh_config`.
      Removes the dead `luke.cartledge` entry.

### Deferred (do on new laptop)

- **`hosts/<new-hostname>.bash`** — copy `On-M4N9QKTH69-MacBookPro.bash`
  on first boot, after running `hostname -s` to learn the new hostname.
  The source host now lists `smb` in its PACKAGES, so the workaround
  below auto-applies. Procedure in
  [Day-1 step 5](#new-laptop-day-1-procedure).
- **Legacy `git/` directory removal** — see
  [Reference section](#reference-legacy-git-directory-cleanup).

### Batch C — SMB multichannel workaround (2026-06-16)

**Goal:** route around a macOS Tahoe 26.5.x `smbfs.kext` bug that hangs
the Wi-Fi driver under sustained SMB load. Surfaced and proven in a
separate "WiFi keeps dropping" investigation — genuine Apple bug, no
clean native fix; `mc_on=no` is the workaround. Deploys via dotfiles so
the new laptop gets it for free.

- [x] **`home/smb/install.bash`** — deploys `/etc/nsmb.conf` via
      `sudo install -m 644 -o root -g wheel` (copy not symlink, since
      `/etc` is root-owned and a symlink into a user-writable dotfiles
      path is a security smell that wouldn't survive macOS updates
      touching `/etc`). Idempotent: no-op if existing file matches
      source byte-for-byte; otherwise backs up and replaces.
- [x] **`home/smb/nsmb.conf`** — `[default]\nmc_on=no`. Header comment
      links to the diagnosis note for future-me.
- [x] **`hosts/On-M4N9QKTH69-MacBookPro.bash`** — added `smb` to
      `PACKAGES`. Means new laptop's host config (copied from this one
      per Day-1 step 6) inherits it automatically.
- [x] **`hosts/mighty-mini.bash`** — added `smb` to `PACKAGES`.
- [x] **Removed `hosts/Luke-Cartledge-MacBookPro.bash`** — work-issued
      MacBook was renamed; superseded by On-M4N9QKTH69. Reduces the
      "which host config is real?" confusion on the new laptop.

**Diagnosis & evidence:** `~/notes/brain/20-work/sessions/2026/06/2026-06-12-wifi-smb-tahoe-bug-dead-end.md`
documents both bugs (Private Wi-Fi Address rotation + SMB multichannel),
the protocol-isolation proof, and the test results.

**Revisit when:** Apple ships an `smbfs`/multichannel fix. The
`mc_on=no` knob can probably be removed at that point — the runbook
will outlive the bug.

### What shipped — 2026-06-16

Three commits, pushed to `origin/master` after rebasing onto Dependabot
+ Ollama-provider commits:

- `c7ea47f feat(smb): add nsmb.conf package to disable multichannel`
- `ce88f1a feat(hosts): enable smb package on macOS hosts`
- `abc7d2c chore(hosts): remove stale Luke-Cartledge-MacBookPro host`

Files added (2): `home/smb/install.bash`, `home/smb/nsmb.conf`.
Files modified (2): two host configs.
Files deleted (1): `hosts/Luke-Cartledge-MacBookPro.bash`.

Verified: `make lint` passed, `script/run --dry` after the host fix
processes the smb package without error, idempotency confirmed (running
`script/run` on Mighty-Mini was a no-op for `/etc/nsmb.conf` since the
file was already in place from the manual deploy proven 2026-06-13 at
home).

The diagnosis itself spanned 2026-06-12 to 2026-06-13 (5 sessions to
untangle two simultaneous bugs); see linked session note for the full
investigation. The dotfiles changes followed three days later.

### What shipped — 2026-06-14

Verified state after applying both batches on Mighty-Mini:

- **`make check`** — ShellCheck passed, 45/45 BATS tests passing
  (incl. meta-tests "every link.bash is valid bash syntax" and
  "every install.bash is valid bash syntax").
- **`bin/check-baseline`** — 37 passed, 5 warned, 3 failed:
  - **Warned**: `ghostty (cask)` and `~/.config/ghostty/config` are
    work-host-only (this is Mighty-Mini, expected),
    `zsh-autosuggestions`/`zsh-syntax-highlighting` shown as warned
    in the brew check (will be replaced with omz-plugin-dir checks in
    a future iteration), Touch-ID-for-sudo not enabled here yet
    (run `script/bootstrap` to apply).
  - **Failed**: `mise which node/ruby/bun` — these confirm the C6
    audit finding. `mise install` has never been run on this machine,
    so the declared runtimes (node 22, ruby, bun) aren't actually
    installed. Run `mise install` manually to clear, or run
    `script/run` to apply the new `home/mise/install.bash` step.
- **All Batch A symlinks live**: `~/.p10k.zsh`, `~/.zprofile` confirmed
  via `ls -la` after `script/run`.

Files added (8):

- `docs/NEW-LAPTOP-RUNBOOK.md` (this file)
- `home/zsh/zprofile`
- `home/zsh/install.bash`
- `home/system/localrc.example`
- `home/ssh/allowed_signers` (reference; not linked)
- `home/ssh/install.bash`
- `home/mise/install.bash`
- `bin/check-baseline` (executable)

Files modified (6):

- `Brewfile` — added `ghostty` cask.
- `home/zsh/link.bash` — added `zprofile` and `p10k.zsh` symlinks.
- `home/opencode/link.bash` — added `~/notes/brain` existence guard
  with actionable warning.
- `home/ssh/config` — collapsed two stale absolute-path Includes
  into a single `Include ~/.colima/ssh_config`.
- `script/bootstrap` — added 5 functions (`install_xcode_clt`,
  `install_rosetta`, `enable_touchid_sudo`, `enable_firewall`,
  `print_manual_steps`) and reordered the main flow to call them.
- `macos/set-defaults.sh` — added `#!/usr/bin/env bash` shebang
  (was relying on `/bin/sh` fallback, which would break the bash
  syntax in the file).

---

## Pre-wipe checklist (do on the OLD laptop)

Run these **before** wiping the old laptop. They preserve everything the
dotfiles don't manage.

### Required

- [ ] Run `bin/check-baseline` (after Batch B lands) to confirm current
      machine is healthy first.
- [ ] **Back up `~/.localrc`** — copy contents to a 1Password Secure Note
      titled "localrc tokens (lukecartledge)". Confirm every var listed in
      `home/system/localrc.example` is in the note.
- [ ] **Export GPG private key (if you use GPG-format signing for anything)**
      — `gpg --export-secret-keys --armor your@email > /tmp/gpg.asc` →
      upload as a 1Password document → `rm /tmp/gpg.asc`.
- [ ] **Confirm SSH private key is in 1Password** — Settings → Developer →
      SSH Agent. If not, copy `~/.ssh/id_ed25519` into a 1Password SSH key
      item.
- [ ] **Brewfile drift reconciliation** — `cd ~/.dotfiles && brew bundle dump
      --file Brewfile.dump --force && diff Brewfile Brewfile.dump`. Reconcile
      any drift, commit, push.
- [ ] **Push every git branch** — `cd ~/.dotfiles && git status` (clean) +
      `git push --all`. Same for `~/notes/brain`.
- [ ] **Confirm `~/notes/brain` is pushed** to its remote.
- [ ] **Final commit + push of dotfiles** — including everything from this
      runbook.

### High-value (optional but strongly recommended)

- [ ] `code --list-extensions > /tmp/vscode-extensions.txt` → upload to
      1Password as a secure note (or commit to a `home/vscode/extensions.txt`
      if you choose to track VSCode).
- [ ] `cp ~/Library/Application\ Support/Code/User/settings.json
      /tmp/vscode-settings.json` → 1Password.
- [ ] In Alfred: Preferences → Advanced → Set sync folder to a known
      location (Dropbox or `~/.dotfiles/home/alfred/`). Alfred handles the
      rest automatically.
- [ ] Export Rectangle Pro layouts via Rectangle Pro → File → Export.
- [ ] `cp ~/.docker/config.json /tmp/docker-config.json` → 1Password
      (or commit to a future `home/docker/`).
- [ ] `cp ~/.colima/default/colima.yaml /tmp/colima.yaml` → 1Password.
- [ ] `cp ~/.gnupg/common.conf /tmp/gnupg-common.conf` → 1Password.
- [ ] Note any apps installed manually (not via Homebrew) — `ls /Applications`
      and cross-reference with `brew bundle list --cask`.

### Sanity check before wiping

- [ ] `git log --show-signature -1` shows valid signature.
- [ ] `op signin` works (1Password CLI).
- [ ] Test machine still boots cleanly.

---

## New-laptop Day-1 procedure

**Order matters.** Some steps depend on earlier ones.

### Phase 0 — pre-bootstrap

1. **Sign into iCloud, App Store, 1Password.**
   The 1Password desktop app + browser extension is critical for retrieving
   `~/.localrc` and SSH keys. Enable Touch ID unlock.

2. **Generate SSH key in 1Password** (recommended) or restore from 1Password.
   - In 1Password: Settings → Developer → enable SSH Agent.
   - Add the public key to your GitHub account
     (https://github.com/settings/keys).
   - Test: `ssh -T git@github.com` should succeed.

3. **Install Xcode Command Line Tools.**
   The bootstrap script will do this, but it's worth pre-running so the
   GUI dialog completes first:
   ```sh
   xcode-select --install
   ```
   Wait for the dialog to complete.

4. **Set hostname (optional, recommended).**
   ```sh
   sudo scutil --set ComputerName "On-<NEW-SERIAL>-MacBookPro"
   sudo scutil --set HostName    "On-<NEW-SERIAL>-MacBookPro"
   sudo scutil --set LocalHostName "On-<NEW-SERIAL>-MacBookPro"
   ```
   This influences the host config filename matched by bootstrap.

### Phase 1 — clone repos

5. **Clone dotfiles.**
   ```sh
   git clone https://github.com/lukecartledge/dotfiles.git ~/.dotfiles
   ```

6. **Create the host config file.**
   ```sh
   cd ~/.dotfiles
   hostname -s   # note this value
   cp hosts/On-M4N9QKTH69-MacBookPro.bash hosts/$(hostname -s).bash
   git add hosts/$(hostname -s).bash
   git commit -m "Add host config for $(hostname -s)"
   git push
   ```
   Doing this **before** bootstrap means bootstrap won't drop into its
   minimal-default prompt path.

7. **Clone the Obsidian brain vault.**
   ```sh
   mkdir -p ~/notes
   git clone <brain-vault-remote> ~/notes/brain
   ```
   This must happen **before** opencode/link.bash runs, or the new
   skills-vault guard will warn and skip the symlinks.

### Phase 2 — bootstrap

8. **Run bootstrap.**
   ```sh
   cd ~/.dotfiles
   script/bootstrap
   ```
   - Touch ID will prompt once for sudo (Touch ID for sudo gets enabled
     mid-flow, then subsequent sudo calls use Touch ID).
   - Rosetta 2 install if Apple Silicon and not already installed.
   - Xcode CLT verified.
   - Homebrew installed, `brew bundle` runs.
   - oh-my-zsh + p10k installed (via `home/zsh/install.bash`).
   - Mise runtimes installed (via `home/mise/install.bash`).
   - SSH key generated if absent (via `home/ssh/install.bash`).
   - All symlinks created.
   - TCC manual-steps checklist printed at end.

### Phase 3 — post-bootstrap manual steps

9. **Restore `~/.localrc`.**
   - Open the 1Password Secure Note "localrc tokens (lukecartledge)".
   - Open the example: `~/.dotfiles/home/system/localrc.example`.
   - Create `~/.localrc` populated with values from the 1Password note.
   - **Required first var:** `export OPENCODE_CONFIG="$HOME/.config/opencode/opencode.local.json"`
     — without this opencode won't load the per-host overlay.

10. **GitHub CLI auth.**
    ```sh
    gh auth login
    ```
    Required for the `gh auth git-credential` helper that gitconfig uses
    for HTTPS GitHub operations.

11. **Re-run `git/install.bash` if necessary.**
    If the SSH key was generated by step 8 (rather than restored in step 2),
    `gitconfig.local` was created without a `signingkey`. Fix:
    ```sh
    rm ~/.gitconfig.local
    cd ~/.dotfiles
    source script/common.bash
    HOME_DIR=$PWD/home source home/git/install.bash
    ```

12. **OpenCode plugin install.**
    ```sh
    cd ~/.config/opencode
    npm install   # or bun install
    ```

13. **Grant TCC permissions** per the bootstrap checklist:
    System Settings → Privacy & Security:
    - Screen Recording → Ghostty, Raycast
    - Accessibility → Raycast, Karabiner (if installed)
    - Full Disk Access → Ghostty, Backup tools
    - Input Monitoring → Karabiner (if installed)

14. **Authenticate work MCPs** (on first use in opencode):
    - `atlassian` MCP — OAuth flow on first opencode invocation.
    - `incident-io` MCP — OAuth flow on first opencode invocation.
    - `github-copilot` provider — uses `gh` token from step 10.

15. **Restore high-value untracked configs from 1Password / pre-wipe backups:**
    - `~/.docker/config.json` (if backed up)
    - `~/.colima/default/colima.yaml` (or run `colima start` and tune)
    - `~/.gnupg/common.conf`
    - VSCode `settings.json`, `keybindings.json`, install extensions from
      `extensions.txt`
    - Alfred sync folder pointer
    - Rectangle Pro layout import

16. **Restart shell.**
    ```sh
    exec zsh -l
    ```

---

## Post-bootstrap verification

After Day-1, run the health check:

```sh
~/.dotfiles/bin/check-baseline
```

Expected output: all green. Any red item is an actionable failure with a
fix command printed inline.

Manual smoke tests:

- [ ] `brew --version` — Homebrew installed, on PATH.
- [ ] `mise current` — runtime versions match `home/mise/config/config.toml`.
- [ ] `git commit --allow-empty -m "test"` then `git log --show-signature -1`
      — signed and verified.
- [ ] `gh auth status` — authenticated.
- [ ] Open Ghostty, prompt should show full p10k segments
      (icon, dir, git, kubernetes context if any).
- [ ] `opencode` launches, `/skills` lists custom + gathered skills.
- [ ] `op signin && op item list | head` — 1Password CLI works.
- [ ] Touch ID prompts for `sudo` (not password).

---

## Reusing this runbook for future migrations

This runbook is meant to outlive this specific migration. For future
laptop replacements:

1. Re-run the audit with the same five-angle parallel investigation
   pattern (`script/bootstrap` flow, tracked-vs-untracked, link.bash
   integrity, secrets/identity, best-practice gaps). The document at
   `docs/NEW-LAPTOP-RUNBOOK.md` you're reading is the output of that
   pattern.
2. Replace the **Audit findings** section with new findings.
3. Add a new **Repo changes plan** section dated and titled by the
   migration (e.g. "Batch C — 2027 Mx work laptop migration").
4. The pre-wipe checklist + Day-1 procedure should largely be reusable.
   Update items as the toolchain evolves.
5. Run `bin/check-baseline` on the OLD machine first; any red item is
   something missing from the dotfiles that should be tracked before
   the wipe.

---

## Reference: legacy `git/` directory cleanup

**Status:** documented, not auto-applied. Do this only after the new
laptop is fully working with the new flow.

The repo has a 2022-era `git/` directory at the root (separate from
`home/git/`). It contains `gitconfig.local.symlink`, leftover from the
holman fork's pre-refactor structure. The current machine's
`~/.gitconfig.local` is a symlink **to that file** — removing the
directory will break git identity until `home/git/install.bash` is
re-run.

Safe procedure:

```sh
# 1. On the NEW laptop, after a successful bootstrap, confirm
#    home/git/install.bash created a fresh ~/.gitconfig.local:
ls -la ~/.gitconfig.local
# Expected: regular file (not a symlink), modern format.

# 2. Confirm no remaining references in the repo:
cd ~/.dotfiles
grep -r "git/gitconfig.local.symlink\|gitconfig.local.symlink" \
  --exclude-dir=.git --exclude-dir=test || echo "no references"

# 3. If clean, remove the legacy directory:
git rm -r git/
git commit -m "Remove legacy holman-era git/ directory"
git push

# 4. On the OLD machine (still running until you wipe), the symlink
#    will break on next pull. Either rebuild ~/.gitconfig.local from
#    1Password backup, or re-run install.bash:
rm ~/.gitconfig.local
HOME_DIR=$HOME/.dotfiles/home source ~/.dotfiles/home/git/install.bash
```

If in doubt, leave the directory alone. It's 1.6 KB of dead weight; not
worth breaking anything.
