#!/usr/bin/env bats

load helpers/setup

link_agent_config() {
  export HOME_DIR="$REPO_ROOT/home"
  export CURR_HOST="On-test"
  run bash -c 'source "$REPO_ROOT/script/common.bash"; source "$HOME_DIR/$1/link.bash"' bash "$1"
  [ "$status" -eq 0 ]
}

@test "OmO Native global instructions link to the shared core" {
  link_agent_config omo
  [ "$(readlink "$HOME/.omo/agent/AGENTS.md")" = "$REPO_ROOT/home/shared/agent-instructions-core.md" ]
}

@test "OmO unified config is seeded as a regular file" {
  link_agent_config omo
  [ -f "$HOME/.omo/omo.jsonc" ]
  [ ! -L "$HOME/.omo/omo.jsonc" ]
  cmp "$HOME/.omo/omo.jsonc" "$REPO_ROOT/home/omo/config/omo.jsonc"
}

@test "OmO linking preserves edits to an existing runtime config" {
  mkdir -p "$HOME/.omo"
  printf '%s\n' '{"[native]":{"model_profile":"custom/model"}}' > "$HOME/.omo/omo.jsonc"
  cp "$HOME/.omo/omo.jsonc" "$TEST_TMPDIR/expected.jsonc"
  link_agent_config omo
  cmp "$HOME/.omo/omo.jsonc" "$TEST_TMPDIR/expected.jsonc"
}
