#!/usr/bin/env bash
# config-parity-audit.sh — detect drift between OpenCode and Claude Code configs
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
echo "── Skills ──"

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

if [ "$CC_TOTAL" -eq "$VAULT_TOTAL" ]; then
  log_pass "Claude Code sees all ${CC_TOTAL} skills"
else
  log_fail "Claude Code sees ${CC_TOTAL} (expected ${VAULT_TOTAL})"
fi

if [ "$OC_TOTAL" -eq "$VAULT_TOTAL" ]; then
  log_pass "OpenCode sees all ${OC_TOTAL} skills"
else
  log_warn "OpenCode sees ${OC_TOTAL} (expected ${VAULT_TOTAL})"
fi

MISSING_FROM_CC=0
for name in "${VAULT_CUSTOM_NAMES[@]}" "${VAULT_GATHERED_NAMES[@]}"; do
  in_list "$name" "${CC_SKILL_NAMES[@]}" || MISSING_FROM_CC=$((MISSING_FROM_CC + 1))
done

UNEXPECTED_IN_CC=0
for name in "${CC_SKILL_NAMES[@]}"; do
  in_list "$name" "${VAULT_CUSTOM_NAMES[@]}" "${VAULT_GATHERED_NAMES[@]}" || UNEXPECTED_IN_CC=$((UNEXPECTED_IN_CC + 1))
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
  security-reviewer
  tdd-guide
  build-error-resolver
  e2e-runner
  doc-updater
  refactor-cleaner
  go-reviewer
  go-build-resolver
  database-reviewer
)

for a in "${EXPECTED_AGENTS[@]}"; do
  if [ -f "$HOME/.dotfiles/home/claude/agents/$a.md" ]; then
    log_pass "$a"
  else
    log_fail "$a missing from $HOME/.dotfiles/home/claude/agents/"
  fi
done

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

# 7. Symlinks wired by link.bash
echo
echo "── Config symlinks ──"
for target in settings.json agents commands; do
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

echo
echo "══════════════════════════════════════"
echo "PASS: $PASS  WARN: $WARN  FAIL: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo "STATUS: ✓ CLEAN"
else
  echo "STATUS: ✗ DRIFT DETECTED"
fi
