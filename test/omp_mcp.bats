#!/usr/bin/env bats

load helpers/setup

link_omp() {
  export HOME_DIR="$REPO_ROOT/home"
  export CURR_HOST="$1"
  run bash -c 'source "$REPO_ROOT/script/common.bash"; source "$HOME_DIR/omp/link.bash"'
  [ "$status" -eq 0 ]
}

@test "OMP work inventory uses the native managed MCP path" {
  link_omp On-test
  [ "$(readlink "$HOME/.omp/agent/mcp.json")" = "$REPO_ROOT/home/omp/config/mcp.work.json" ]
  [ ! -e "$HOME/.omp/agent/.mcp.json" ]
  run node -e '
    const d = require(process.env.HOME + "/.omp/agent/mcp.json");
    for (const name of ["context-mode", "atlassian", "incident-io", "newrelic", "looker", "google-drive", "bigquery", "slack"]) {
      if (!d.mcpServers[name]) throw Error(name + " missing from native inventory");
    }
    if (d.mcpServers.newrelic.enabled !== false) throw Error("Disabled state changed");
    if (d.mcpServers.atlassian.enabled !== true) throw Error("Active state changed");
  '
  [ "$status" -eq 0 ]
}

@test "OMP personal inventory includes shared servers without enabling org access" {
  link_omp personal-test
  [ "$(readlink "$HOME/.omp/agent/mcp.json")" = "$REPO_ROOT/home/omp/config/mcp.personal.json" ]
  run node -e '
    const d = require(process.env.HOME + "/.omp/agent/mcp.json");
    if (!d.mcpServers["context-mode"] || !d.mcpServers.github || !d.mcpServers.strava) throw Error("Incomplete profile");
    if (d.mcpServers.atlassian.enabled !== false || d.mcpServers["incident-io"].enabled !== false) throw Error("Org servers enabled on personal host");
  '
  [ "$status" -eq 0 ]
}

@test "OMP linking backs up the known legacy discovery symlink" {
  mkdir -p "$HOME/.omp/agent"
  ln -s "$REPO_ROOT/home/omp/config/mcp.work.json" "$HOME/.omp/agent/.mcp.json"
  link_omp On-test
  [ ! -L "$HOME/.omp/agent/.mcp.json" ]
  local backups=("$HOME/.omp/agent/.mcp.json.backup."*)
  [ -L "${backups[0]}" ]
}

@test "OMP linking preserves an unmanaged discovery file" {
  mkdir -p "$HOME/.omp/agent"
  printf '%s\n' '{"mcpServers":{"custom":{"command":"custom-server"}}}' > "$HOME/.omp/agent/.mcp.json"
  cp "$HOME/.omp/agent/.mcp.json" "$TEST_TMPDIR/expected.json"
  link_omp On-test
  cmp "$HOME/.omp/agent/.mcp.json" "$TEST_TMPDIR/expected.json"
}
