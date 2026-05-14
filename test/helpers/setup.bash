#!/usr/bin/env bash
#
# Shared test setup for BATS tests
#
# Every .bats file should load this via:
#   load helpers/setup
#

# Resolve repo root (two levels up from test/helpers/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

# Load assertion libraries
load "$REPO_ROOT/test/test_helper/bats-support/load"
load "$REPO_ROOT/test/test_helper/bats-assert/load"

# Source common.bash into the test environment
# shellcheck source=/dev/null
source "$REPO_ROOT/script/common.bash"

# Per-test temp directory — isolated filesystem sandbox
setup() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME"
  # Default to non-dry-run; tests override as needed
  dry=0
  cmd=""
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}
