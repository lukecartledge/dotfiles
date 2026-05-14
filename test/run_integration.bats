#!/usr/bin/env bats
#
# Integration tests for script/run (dry-run mode)

load helpers/setup

# Override setup to build a fixture dotfiles tree
setup() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME"

  # Build a minimal dotfiles fixture
  FIXTURE_DIR="$TEST_TMPDIR/dotfiles"
  mkdir -p "$FIXTURE_DIR/script" \
           "$FIXTURE_DIR/hosts" \
           "$FIXTURE_DIR/home/mock-pkg-a" \
           "$FIXTURE_DIR/home/mock-pkg-b" \
           "$FIXTURE_DIR/bin"

  # Copy real scripts
  cp "$REPO_ROOT/script/common.bash" "$FIXTURE_DIR/script/common.bash"
  cp "$REPO_ROOT/script/run" "$FIXTURE_DIR/script/run"

  # Create a stub bin/host that returns our test hostname
  cat > "$FIXTURE_DIR/bin/host" <<'STUB'
#!/usr/bin/env bash
echo "test-host"
STUB
  chmod +x "$FIXTURE_DIR/bin/host"

  # Create host config
  cat > "$FIXTURE_DIR/hosts/test-host.bash" <<'HOST'
export SYSTEM="test"
export PACKAGES=(
  mock-pkg-a
  mock-pkg-b
)
HOST

  # Create package link scripts that use common.bash functions
  cat > "$FIXTURE_DIR/home/mock-pkg-a/link.bash" <<'LINK'
link_home "$HOME_DIR/mock-pkg-a/config" "mock-a-config"
LINK

  echo "mock-a-content" > "$FIXTURE_DIR/home/mock-pkg-a/config"

  cat > "$FIXTURE_DIR/home/mock-pkg-b/link.bash" <<'LINK'
link_home "$HOME_DIR/mock-pkg-b/config" "mock-b-config"
LINK

  echo "mock-b-content" > "$FIXTURE_DIR/home/mock-pkg-b/config"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

@test "run dry-run discovers packages from host config" {
  run "$FIXTURE_DIR/script/run" --dry

  assert_success
  assert_output --partial "mock-pkg-a"
  assert_output --partial "mock-pkg-b"
}

@test "run dry-run shows linking operations for each package" {
  run "$FIXTURE_DIR/script/run" --dry

  assert_success
  assert_output --partial "Would link"
}

@test "run dry-run does not create any symlinks" {
  "$FIXTURE_DIR/script/run" --dry

  [ ! -L "$HOME/.mock-a-config" ]
  [ ! -L "$HOME/.mock-b-config" ]
}

@test "run processes packages in order" {
  run "$FIXTURE_DIR/script/run" --dry

  # mock-pkg-a should appear before mock-pkg-b in output
  local a_line b_line
  a_line=$(echo "$output" | grep -n "mock-pkg-a" | head -1 | cut -d: -f1)
  b_line=$(echo "$output" | grep -n "mock-pkg-b" | head -1 | cut -d: -f1)
  [ "$a_line" -lt "$b_line" ]
}

@test "run handles missing package directory gracefully" {
  # Add a non-existent package to the host config
  cat > "$FIXTURE_DIR/hosts/test-host.bash" <<'HOST'
export SYSTEM="test"
export PACKAGES=(
  mock-pkg-a
  nonexistent-pkg
  mock-pkg-b
)
HOST

  run "$FIXTURE_DIR/script/run" --dry

  # Should report the missing package but continue processing
  assert_output --partial "nonexistent-pkg"
  assert_output --partial "FAIL"
  assert_output --partial "mock-pkg-b"
}

@test "run non-dry creates actual symlinks" {
  "$FIXTURE_DIR/script/run"

  [ -L "$HOME/.mock-a-config" ]
  [ -L "$HOME/.mock-b-config" ]
}

@test "run fails when host config is missing" {
  rm "$FIXTURE_DIR/hosts/test-host.bash"

  run "$FIXTURE_DIR/script/run"

  assert_failure
  assert_output --partial "No host configuration found"
}
