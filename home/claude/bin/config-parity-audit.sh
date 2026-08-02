#!/usr/bin/env bash
# config-parity-audit.sh — detect drift between OpenCode and Claude Code configs
#
# Model: "sync what you author, diverge what you consume."
#
#   PARITY   — things authored here (custom skills, agents, commands, rules,
#              instructions, MCP). These must match across both harnesses.
#   LEGACY   — gathered/ skills copied from upstream. Being retired in favour of
#              Claude Code plugins; reported for visibility, never a hard fail.
#   CLAUDE-ONLY — the plugin layer. No OpenCode equivalent exists, so it is
#              presence-checked against dotfiles settings.json and never
#              compared against OpenCode.
set -euo pipefail

PASS=0
WARN=0
FAIL=0

log_pass() { printf '  ✓ %s\n' "$*"; PASS=$((PASS + 1)); }
log_warn() { printf '  ⚠ %s\n' "$*"; WARN=$((WARN + 1)); }
log_fail() { printf '  ✗ %s\n' "$*"; FAIL=$((FAIL + 1)); }

list_names() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    return 0
  fi

  local path
  for path in "$dir"/*; do
    [ -e "$path" ] || [ -L "$path" ] || continue
    basename "$path"
  done
}

list_skill_names() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    return 0
  fi

  local path
  for path in "$dir"/*; do
    [ -d "$path" ] || continue
    basename "$path"
  done
}

in_list() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

echo "=== Claude Code / OpenCode Parity Audit ==="
date '+%Y-%m-%d %H:%M'
echo

VAULT_CUSTOM_DIR="$HOME/notes/brain/40-skills/custom"
VAULT_GATHERED_DIR="$HOME/notes/brain/40-skills/gathered"
OC_CUSTOM_DIR="$HOME/.config/opencode/skills/custom"
OC_GATHERED_DIR="$HOME/.config/opencode/skills/gathered"
CC_VAULT_DIR="$HOME/.claude/skills/vault/skills"

# 1. Skill counts + parity by name
#    custom/ is authored here and must match everywhere. gathered/ is upstream
#    material on its way out, so it is counted but never failed on.
echo "── Skills (parity: custom) ──"

mapfile -t VAULT_CUSTOM_NAMES < <(list_skill_names "$VAULT_CUSTOM_DIR" | sort)
mapfile -t VAULT_GATHERED_NAMES < <(list_skill_names "$VAULT_GATHERED_DIR" | sort)
mapfile -t OC_CUSTOM_NAMES < <(list_skill_names "$OC_CUSTOM_DIR" | sort)
mapfile -t OC_GATHERED_NAMES < <(list_skill_names "$OC_GATHERED_DIR" | sort)
mapfile -t CC_SKILL_NAMES < <(list_names "$CC_VAULT_DIR" | sort)

VAULT_CUSTOM_COUNT="${#VAULT_CUSTOM_NAMES[@]}"
VAULT_GATHERED_COUNT="${#VAULT_GATHERED_NAMES[@]}"
VAULT_TOTAL=$((VAULT_CUSTOM_COUNT + VAULT_GATHERED_COUNT))
OC_TOTAL=$(( ${#OC_CUSTOM_NAMES[@]} + ${#OC_GATHERED_NAMES[@]} ))
CC_TOTAL="${#CC_SKILL_NAMES[@]}"

log_pass "Vault skills: ${VAULT_CUSTOM_COUNT} custom + ${VAULT_GATHERED_COUNT} gathered = ${VAULT_TOTAL}"

# custom/ is the authored surface — strict parity on both harnesses.
if [ "${#OC_CUSTOM_NAMES[@]}" -eq "$VAULT_CUSTOM_COUNT" ]; then
  log_pass "OpenCode sees all ${VAULT_CUSTOM_COUNT} custom skills"
else
  log_fail "OpenCode sees ${#OC_CUSTOM_NAMES[@]} custom skills (expected ${VAULT_CUSTOM_COUNT})"
fi

MISSING_CUSTOM_CC=0
for name in ${VAULT_CUSTOM_NAMES[@]+"${VAULT_CUSTOM_NAMES[@]}"}; do
  in_list "$name" ${CC_SKILL_NAMES[@]+"${CC_SKILL_NAMES[@]}"} || MISSING_CUSTOM_CC=$((MISSING_CUSTOM_CC + 1))
done
if [ "$MISSING_CUSTOM_CC" -eq 0 ]; then
  log_pass "Claude Code sees all ${VAULT_CUSTOM_COUNT} custom skills"
else
  log_fail "Claude Code missing ${MISSING_CUSTOM_CC} custom skill(s)"
fi

if [ "$CC_TOTAL" -eq "$VAULT_TOTAL" ]; then
  log_pass "Claude Code link count matches vault (${CC_TOTAL})"
else
  log_fail "Claude Code sees ${CC_TOTAL} skill links (expected ${VAULT_TOTAL}) — re-run link.bash"
fi

# gathered/ is upstream material being replaced by plugins. Shrinking is the
# goal, so report the number without judging it.
echo
echo "── Skills (legacy: gathered) ──"
log_pass "gathered/ holds ${VAULT_GATHERED_COUNT} upstream skill(s) — retire as plugins cover them"
if [ "${#OC_GATHERED_NAMES[@]}" -ne "$VAULT_GATHERED_COUNT" ]; then
  log_warn "OpenCode gathered/ count differs (${#OC_GATHERED_NAMES[@]} vs ${VAULT_GATHERED_COUNT}) — expected while diverging"
fi

# Skill health — a directory is not a skill. Catches empty stubs and skills
# whose frontmatter name disagrees with the directory Claude Code keys on.
echo
echo "── Skill health ──"
EMPTY_SKILLS=0
NAME_MISMATCH=0
for skill_dir in "$VAULT_CUSTOM_DIR"/*/ "$VAULT_GATHERED_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  skill_md="${skill_dir}SKILL.md"
  if [ ! -s "$skill_md" ]; then
    log_fail "$skill_name has an empty or missing SKILL.md"
    EMPTY_SKILLS=$((EMPTY_SKILLS + 1))
    continue
  fi
  fm_name="$(grep -m1 '^name:' "$skill_md" 2>/dev/null | sed 's/^name:[[:space:]]*//' | tr -d '"' || true)"
  if [ -n "$fm_name" ] && [ "$fm_name" != "$skill_name" ]; then
    log_warn "$skill_name: frontmatter name is '$fm_name' (harnesses may disagree on the key)"
    NAME_MISMATCH=$((NAME_MISMATCH + 1))
  fi
done
[ "$EMPTY_SKILLS" -eq 0 ] && log_pass "All skills have a non-empty SKILL.md"
[ "$NAME_MISMATCH" -eq 0 ] && log_pass "All skill directory names match their frontmatter"

echo
echo "── Link integrity ──"
MISSING_FROM_CC=0
for name in ${VAULT_CUSTOM_NAMES[@]+"${VAULT_CUSTOM_NAMES[@]}"} ${VAULT_GATHERED_NAMES[@]+"${VAULT_GATHERED_NAMES[@]}"}; do
  in_list "$name" ${CC_SKILL_NAMES[@]+"${CC_SKILL_NAMES[@]}"} || MISSING_FROM_CC=$((MISSING_FROM_CC + 1))
done

UNEXPECTED_IN_CC=0
for name in ${CC_SKILL_NAMES[@]+"${CC_SKILL_NAMES[@]}"}; do
  in_list "$name" ${VAULT_CUSTOM_NAMES[@]+"${VAULT_CUSTOM_NAMES[@]}"} ${VAULT_GATHERED_NAMES[@]+"${VAULT_GATHERED_NAMES[@]}"} || UNEXPECTED_IN_CC=$((UNEXPECTED_IN_CC + 1))
done

if [ "$MISSING_FROM_CC" -eq 0 ] && [ "$UNEXPECTED_IN_CC" -eq 0 ]; then
  log_pass "Claude Code skill names match vault"
else
  if [ "$MISSING_FROM_CC" -gt 0 ]; then
    log_fail "Claude Code missing ${MISSING_FROM_CC} vault skill link(s)"
  fi
  if [ "$UNEXPECTED_IN_CC" -gt 0 ]; then
    log_warn "Claude Code has ${UNEXPECTED_IN_CC} unexpected skill link(s)"
  fi
fi

# 2. Broken symlinks in Claude Code vault plugin
echo
echo "── Vault symlinks ──"
BROKEN=0
NON_SYMLINK=0
MISSING_EXPECTED=0
ORPHANED=0

EXPECTED_SKILL_NAMES=("${VAULT_CUSTOM_NAMES[@]}" "${VAULT_GATHERED_NAMES[@]}")

if [ -d "$CC_VAULT_DIR" ]; then
  local_path=""

  for expected in "${EXPECTED_SKILL_NAMES[@]}"; do
    local_path="$CC_VAULT_DIR/$expected"
    if [ ! -e "$local_path" ] && [ ! -L "$local_path" ]; then
      MISSING_EXPECTED=$((MISSING_EXPECTED + 1))
      continue
    fi
    if [ ! -L "$local_path" ]; then
      NON_SYMLINK=$((NON_SYMLINK + 1))
      continue
    fi
    [ -e "$local_path" ] || BROKEN=$((BROKEN + 1))
  done

  for l in "$CC_VAULT_DIR"/*; do
    [ -e "$l" ] || [ -L "$l" ] || continue
    name="$(basename "$l")"
    in_list "$name" "${EXPECTED_SKILL_NAMES[@]}" || ORPHANED=$((ORPHANED + 1))
  done
else
  log_fail "Claude vault skills dir missing: $CC_VAULT_DIR"
fi

if [ "$NON_SYMLINK" -eq 0 ]; then
  log_pass "All Claude vault skill entries are symlinks"
else
  if [ "$NON_SYMLINK" -eq 1 ]; then
    log_warn "$NON_SYMLINK non-symlink entry in $CC_VAULT_DIR"
  else
    log_warn "$NON_SYMLINK non-symlink entries in $CC_VAULT_DIR"
  fi
fi

if [ "$BROKEN" -eq 0 ]; then
  log_pass "No broken symlinks in Claude Code vault plugin"
else
  log_fail "$BROKEN broken symlink(s) in $CC_VAULT_DIR"
fi

if [ "$MISSING_EXPECTED" -eq 0 ]; then
  log_pass "No missing expected symlink names in Claude vault"
else
  log_fail "$MISSING_EXPECTED broken/missing symlink name(s) in $CC_VAULT_DIR"
fi

if [ "$ORPHANED" -eq 0 ]; then
  log_pass "No orphaned symlink names in Claude vault"
else
  log_warn "$ORPHANED orphaned symlink name(s) in $CC_VAULT_DIR"
fi

# 3. Agents — key domain agents present in Claude Code
echo
echo "── Domain agents ──"
EXPECTED_AGENTS=(
  planner
  architect
  code-reviewer
  security-reviewer
  tdd-guide
  build-error-resolver
  e2e-runner
  doc-updater
  refactor-cleaner
  database-reviewer
)

CC_AGENTS_DIR="$HOME/.dotfiles/home/claude/agents"
OC_CONFIG="$HOME/.dotfiles/home/opencode/config/opencode.json"

# Agents are an authored surface, so both harnesses must carry the same set.
# Checking only one side lets a removal on the other pass silently.
for a in "${EXPECTED_AGENTS[@]}"; do
  in_cc=0; in_oc=0
  [ -f "$CC_AGENTS_DIR/$a.md" ] && in_cc=1
  if command -v jq >/dev/null 2>&1 && [ -f "$OC_CONFIG" ]; then
    jq -e --arg a "$a" '(.agent // {}) | has($a)' "$OC_CONFIG" >/dev/null 2>&1 && in_oc=1
  else
    in_oc=1  # cannot verify without jq — do not report a false mismatch
  fi

  if [ "$in_cc" -eq 1 ] && [ "$in_oc" -eq 1 ]; then
    log_pass "$a"
  elif [ "$in_cc" -eq 1 ]; then
    log_fail "$a in Claude Code but missing from opencode.json"
  elif [ "$in_oc" -eq 1 ]; then
    log_fail "$a in opencode.json but missing from $CC_AGENTS_DIR"
  else
    log_fail "$a missing from both harnesses — drop it from EXPECTED_AGENTS"
  fi
done

# Agents defined in either harness but absent from EXPECTED_AGENTS are drift:
# they were added or removed without the parity contract being updated.
for f in "$CC_AGENTS_DIR"/*.md; do
  [ -f "$f" ] || continue
  a="$(basename "$f" .md)"
  in_list "$a" "${EXPECTED_AGENTS[@]}" || log_warn "$a present in Claude Code but not tracked in EXPECTED_AGENTS"
done
if command -v jq >/dev/null 2>&1 && [ -f "$OC_CONFIG" ]; then
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    in_list "$a" "${EXPECTED_AGENTS[@]}" || log_warn "$a present in OpenCode but not tracked in EXPECTED_AGENTS"
  done < <(jq -r '(.agent // {}) | keys[]' "$OC_CONFIG" 2>/dev/null || true)
fi

# 4. Commands — key ported commands present, SKIP list absent
echo
echo "── Commands ──"
EXPECTED_CMDS=(tdd verify code-review security plan save-session new-skill new-project)
for c in "${EXPECTED_CMDS[@]}"; do
  if [ -f "$HOME/.dotfiles/home/claude/commands/$c.md" ]; then
    log_pass "$c"
  else
    log_fail "$c missing from $HOME/.dotfiles/home/claude/commands/"
  fi
done

SKIP_CMDS=(instinct-status evolve promote loop-start orchestrate model-route)
for c in "${SKIP_CMDS[@]}"; do
  if [ ! -f "$HOME/.dotfiles/home/claude/commands/$c.md" ]; then
    log_pass "$c correctly absent (OMO-only)"
  else
    log_fail "$c present — should be excluded (OMO-only command)"
  fi
done

# 5. MCP servers — Claude Code should have expected user-scope servers
echo
echo "── MCP servers ──"
if command -v claude >/dev/null 2>&1; then
  MCP_OUT="$(claude mcp list 2>/dev/null || true)"
  if [ -z "$MCP_OUT" ]; then
    log_warn "claude mcp list returned no data — check auth/session"
  else
    for s in atlassian contentful github newrelic context-mode obsidian; do
      if printf '%s\n' "$MCP_OUT" | grep -qi "\b$s\b"; then
        log_pass "Claude Code: $s"
      else
        log_fail "Claude Code: $s missing from claude mcp list"
      fi
    done
  fi
else
  log_warn "claude CLI not in PATH — skipping MCP check"
fi

# 6. Instruction source — shared core referenced by both tools
echo
echo "── Instructions ──"
if [ -f "$HOME/.dotfiles/home/shared/agent-instructions-core.md" ]; then
  log_pass "Shared core exists"
else
  log_fail "Shared core missing: $HOME/.dotfiles/home/shared/agent-instructions-core.md"
fi

if grep -q 'agent-instructions-core' "$HOME/.dotfiles/home/claude/CLAUDE.md" 2>/dev/null; then
  log_pass "CLAUDE.md @imports shared core"
else
  log_fail "CLAUDE.md does not import shared core"
fi

if command -v jq >/dev/null 2>&1; then
  if jq -e '.instructions | map(test("agent-instructions-core")) | any' "$HOME/.dotfiles/home/opencode/config/opencode.json" >/dev/null 2>&1; then
    log_pass "opencode.json references shared core"
  else
    log_fail "opencode.json does not reference shared core"
  fi
else
  log_warn "jq not installed — skipping opencode instruction reference check"
fi

# 7. Rules — Claude Code auto-loads these into every session, so they must be
#    version-controlled in dotfiles rather than living only in ~/.claude.
echo
echo "── Rules ──"
RULES_DIR="$HOME/.dotfiles/home/claude/rules"
EXPECTED_RULES=(
  common/coding-style.md
  common/git-workflow.md
  common/testing.md
  common/performance.md
  common/patterns.md
  common/hooks.md
  common/development-workflow.md
  common/agents.md
  common/security.md
)
for r in "${EXPECTED_RULES[@]}"; do
  if [ -f "$RULES_DIR/$r" ]; then
    log_pass "$r"
  else
    log_fail "$r missing from $RULES_DIR"
  fi
done

# 8. Symlinks wired by link.bash
echo
echo "── Config symlinks ──"
for target in settings.json agents commands rules keybindings.json; do
  claude_path="$HOME/.claude/$target"
  if [ -L "$claude_path" ]; then
    dest="$(readlink "$claude_path" 2>/dev/null || true)"
    case "$dest" in
      *dotfiles*) log_pass "$HOME/.claude/$target → dotfiles" ;;
      *) log_warn "$HOME/.claude/$target exists but not pointing to dotfiles" ;;
    esac
  else
    log_fail "$HOME/.claude/$target is not a symlink"
  fi
done

# 9. Plugin layer — Claude Code only. OpenCode has no plugin/marketplace
#    equivalent, so this is deliberately NOT compared against it. We only assert
#    that what dotfiles declares is what the machine actually has.
echo
echo "── Plugin layer (Claude Code only) ──"
CC_SETTINGS="$HOME/.dotfiles/home/claude/settings.json"
INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"

if ! command -v jq >/dev/null 2>&1; then
  log_warn "jq not installed — skipping plugin layer check"
elif [ ! -f "$CC_SETTINGS" ]; then
  log_fail "settings.json missing: $CC_SETTINGS"
else
  # Every marketplace declared in dotfiles must be registered locally.
  while IFS= read -r mkt; do
    [ -n "$mkt" ] || continue
    if [ -f "$KNOWN_MARKETPLACES" ] && jq -e --arg m "$mkt" 'has($m)' "$KNOWN_MARKETPLACES" >/dev/null 2>&1; then
      log_pass "marketplace: $mkt"
    else
      log_fail "marketplace '$mkt' declared in dotfiles but not registered — run: claude plugin marketplace add"
    fi
  done < <(jq -r '(.extraKnownMarketplaces // {}) | keys[]' "$CC_SETTINGS" 2>/dev/null || true)

  # Every plugin enabled in dotfiles must actually be installed.
  DECLARED_PLUGINS=0
  while IFS= read -r plug; do
    [ -n "$plug" ] || continue
    DECLARED_PLUGINS=$((DECLARED_PLUGINS + 1))
    if [ -f "$INSTALLED_PLUGINS" ] && jq -e --arg p "$plug" '.plugins | has($p)' "$INSTALLED_PLUGINS" >/dev/null 2>&1; then
      log_pass "plugin: $plug"
    else
      log_fail "plugin '$plug' enabled in dotfiles but not installed — run: claude plugin install $plug"
    fi
  done < <(jq -r '(.enabledPlugins // {}) | to_entries[] | select(.value) | .key' "$CC_SETTINGS" 2>/dev/null || true)

  [ "$DECLARED_PLUGINS" -eq 0 ] && log_warn "no plugins declared in settings.json"

  # Plugins declared false are off on purpose. Report them so an intentional
  # opt-out stays visible and is not mistaken for one that went missing.
  while IFS= read -r plug; do
    [ -n "$plug" ] || continue
    if [ -f "$INSTALLED_PLUGINS" ] && jq -e --arg p "$plug" '.plugins | has($p)' "$INSTALLED_PLUGINS" >/dev/null 2>&1; then
      log_pass "plugin: $plug (disabled by default — enable per project when needed)"
    else
      log_warn "plugin '$plug' is declared disabled but is not installed — enabling it will require a download"
    fi
  done < <(jq -r '(.enabledPlugins // {}) | to_entries[] | select(.value | not) | .key' "$CC_SETTINGS" 2>/dev/null || true)

  # Installed but undeclared plugins will not survive a rebuild from dotfiles.
  if [ -f "$INSTALLED_PLUGINS" ]; then
    while IFS= read -r plug; do
      [ -n "$plug" ] || continue
      if ! jq -e --arg p "$plug" '(.enabledPlugins // {}) | has($p)' "$CC_SETTINGS" >/dev/null 2>&1; then
        log_warn "plugin '$plug' installed but not declared in dotfiles — it will not survive a fresh machine"
      fi
    done < <(jq -r '.plugins | keys[]' "$INSTALLED_PLUGINS" 2>/dev/null || true)
  fi
fi

echo
echo "══════════════════════════════════════"
echo "PASS: $PASS  WARN: $WARN  FAIL: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo "STATUS: ✓ CLEAN"
else
  echo "STATUS: ✗ DRIFT DETECTED"
fi
