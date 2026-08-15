#!/bin/sh
# Claude Code status line — session state only.
#
# Deliberately omits cwd, git branch and the clock: the tmux status bar already
# shows all three. This line carries only what tmux cannot know — context burn,
# rate-limit headroom, spend and churn for the current Claude Code session.
#
# Payload reference: https://code.claude.com/docs/en/statusline

input=$(cat)

# One jq pass for every field, so the line costs a single subprocess.
# Missing fields collapse to sentinels (-1 for percentages) and are skipped.
fields=$(printf '%s' "$input" | jq -r '
  [ .model.display_name // ""
  , .effort.level // ""
  , (.fast_mode // false | tostring)
  , (.context_window.used_percentage // -1 | floor | tostring)
  , (.rate_limits.five_hour.used_percentage // -1 | floor | tostring)
  , (.rate_limits.five_hour.resets_at // 0 | tostring)
  , (.cost.total_cost_usd // 0 | tostring)
  , (.cost.total_lines_added // 0 | tostring)
  , (.cost.total_lines_removed // 0 | tostring)
  ] | .[]')

# One field per line, read one at a time. Tab-separated + a single `read` would
# be shorter but wrong: tab is IFS whitespace, so empty fields (absent effort,
# no rate limits) collapse and silently shift every later value left.
{
  IFS= read -r model
  IFS= read -r effort
  IFS= read -r fast
  IFS= read -r ctx
  IFS= read -r rl5
  IFS= read -r rl5_reset
  IFS= read -r cost
  IFS= read -r added
  IFS= read -r removed
} <<EOF
$fields
EOF

RESET=$(printf '\033[0m')
DIM=$(printf '\033[38;5;244m')
BRIGHT=$(printf '\033[38;5;252m')
GREEN=$(printf '\033[38;5;76m')
RED=$(printf '\033[38;5;203m')

# Green under 50%, amber from 50%, red from 75%.
pct_color() {
  if [ "$1" -ge 75 ]; then
    printf '\033[38;5;203m'
  elif [ "$1" -ge 50 ]; then
    printf '\033[38;5;178m'
  else
    printf '\033[38;5;76m'
  fi
}

# Epoch seconds to HH:MM, BSD (macOS) first then GNU.
clock_at() {
  date -r "$1" +%H:%M 2>/dev/null || date -d "@$1" +%H:%M 2>/dev/null
}

out="${BRIGHT}${model}${RESET}"
[ -n "$effort" ] && out="${out} ${DIM}· ${effort}${RESET}"
[ "$fast" = "true" ] && out="${out} ${DIM}· fast${RESET}"

if [ "$ctx" -ge 0 ]; then
  out="${out}  ${DIM}ctx${RESET} $(pct_color "$ctx")${ctx}%${RESET}"
fi

if [ "$rl5" -ge 0 ]; then
  out="${out}  ${DIM}5h${RESET} $(pct_color "$rl5")${rl5}%${RESET}"
  # Only worth the width once the window is half spent.
  if [ "$rl5" -ge 50 ] && [ "$rl5_reset" -gt 0 ]; then
    resets=$(clock_at "$rl5_reset")
    [ -n "$resets" ] && out="${out} ${DIM}resets ${resets}${RESET}"
  fi
fi

out="${out}  ${DIM}$(printf '$%.2f' "$cost")${RESET}"

if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
  out="${out}  ${GREEN}+${added}${RESET}${DIM}/${RESET}${RED}-${removed}${RESET}"
fi

printf '%s\n' "$out"
