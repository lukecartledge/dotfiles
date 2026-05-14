#!/usr/bin/env bats
#
# Unit tests for the extract function

load helpers/setup

# Override setup to create stub commands and fixture archive files
setup() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME"

  # Stub bin directory — prepended to PATH so stubs intercept real commands
  STUB_DIR="$TEST_TMPDIR/stubs"
  mkdir -p "$STUB_DIR"
  export CALL_LOG="$TEST_TMPDIR/calls.log"
  : > "$CALL_LOG"

  # Create stubs for each extraction tool
  for cmd in tar bunzip2 hdiutil gunzip unzip pax uncompress unrar cat; do
    cat > "$STUB_DIR/$cmd" <<STUB
#!/usr/bin/env bash
echo "$cmd \$*" >> "$CALL_LOG"
STUB
    chmod +x "$STUB_DIR/$cmd"
  done

  export PATH="$STUB_DIR:$PATH"

  # Source the extract function
  # shellcheck source=/dev/null
  source "$REPO_ROOT/home/functions/zsh-functions/extract"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

# Helper: create a fixture file and run extract on it
run_extract() {
  local filename="$1"
  local filepath="$TEST_TMPDIR/$filename"
  touch "$filepath"
  run extract "$filepath"
}

@test "extract .tar.bz2 dispatches to tar -jxvf" {
  run_extract "archive.tar.bz2"

  assert_success
  run /usr/bin/grep -F "tar -jxvf" "$CALL_LOG"
  assert_success
}

@test "extract .tar.gz dispatches to tar -zxvf" {
  run_extract "archive.tar.gz"

  assert_success
  run /usr/bin/grep -F "tar -zxvf" "$CALL_LOG"
  assert_success
}

@test "extract .bz2 dispatches to bunzip2" {
  run_extract "archive.bz2"

  assert_success
  run /usr/bin/grep -F "bunzip2" "$CALL_LOG"
  assert_success
}

@test "extract .dmg dispatches to hdiutil mount" {
  run_extract "disk.dmg"

  assert_success
  run /usr/bin/grep -F "hdiutil mount" "$CALL_LOG"
  assert_success
}

@test "extract .gz dispatches to gunzip" {
  run_extract "archive.gz"

  assert_success
  run /usr/bin/grep -F "gunzip" "$CALL_LOG"
  assert_success
}

@test "extract .tar dispatches to tar -xvf" {
  run_extract "archive.tar"

  assert_success
  run /usr/bin/grep -F "tar -xvf" "$CALL_LOG"
  assert_success
}

@test "extract .tbz2 dispatches to tar -jxvf" {
  run_extract "archive.tbz2"

  assert_success
  run /usr/bin/grep -F "tar -jxvf" "$CALL_LOG"
  assert_success
}

@test "extract .tgz dispatches to tar -zxvf" {
  run_extract "archive.tgz"

  assert_success
  run /usr/bin/grep -F "tar -zxvf" "$CALL_LOG"
  assert_success
}

@test "extract .zip dispatches to unzip" {
  run_extract "archive.zip"

  assert_success
  run /usr/bin/grep -F "unzip" "$CALL_LOG"
  assert_success
}

@test "extract .ZIP dispatches to unzip" {
  run_extract "ARCHIVE.ZIP"

  assert_success
  run /usr/bin/grep -F "unzip" "$CALL_LOG"
  assert_success
}

@test "extract .rar dispatches to unrar x" {
  run_extract "archive.rar"

  assert_success
  run /usr/bin/grep -F "unrar x" "$CALL_LOG"
  assert_success
}

@test "extract .Z dispatches to uncompress" {
  run_extract "archive.Z"

  assert_success
  run /usr/bin/grep -F "uncompress" "$CALL_LOG"
  assert_success
}

@test "extract unknown extension outputs error" {
  run_extract "archive.xyz"

  assert_output --partial "cannot be extracted"
}

@test "extract nonexistent file outputs error" {
  run extract "$TEST_TMPDIR/nonexistent.tar.gz"

  assert_output --partial "is not a valid file"
}
