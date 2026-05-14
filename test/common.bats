#!/usr/bin/env bats
#
# Unit tests for script/common.bash

load helpers/setup

# --- link() ---

@test "link creates symlink to correct target" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/dest.conf"
  echo "content" > "$src"

  run link "$src" "$dst"

  assert_success
  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "link skips when symlink already correct" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/dest.conf"
  echo "content" > "$src"
  ln -s "$src" "$dst"

  run link "$src" "$dst"

  assert_success
  assert_output --partial "Already linked"
}

@test "link backs up existing non-symlink file" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/dest.conf"
  echo "source" > "$src"
  echo "existing" > "$dst"

  run link "$src" "$dst"

  assert_success
  [ -L "$dst" ]
  # Backup file should exist with .backup. prefix
  local backup_count
  backup_count=$(find "$TEST_TMPDIR" -maxdepth 1 -name 'dest.conf.backup.*' | wc -l)
  [ "$backup_count" -eq 1 ]
}

@test "link replaces incorrect symlink with backup" {
  local src="$TEST_TMPDIR/source.conf"
  local wrong_src="$TEST_TMPDIR/wrong.conf"
  local dst="$TEST_TMPDIR/dest.conf"
  echo "source" > "$src"
  echo "wrong" > "$wrong_src"
  ln -s "$wrong_src" "$dst"

  run link "$src" "$dst"

  assert_success
  [ -L "$dst" ]
  [ "$(readlink "$dst")" = "$src" ]
}

@test "link creates parent directories when missing" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/deep/nested/dir/dest.conf"
  echo "content" > "$src"

  run link "$src" "$dst"

  assert_success
  [ -d "$TEST_TMPDIR/deep/nested/dir" ]
  [ -L "$dst" ]
}

@test "link fails when source does not exist" {
  run link "$TEST_TMPDIR/nonexistent" "$TEST_TMPDIR/dest"

  assert_failure
  assert_output --partial "Source does not exist"
}

@test "link dry-run does not create symlink" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/dest.conf"
  echo "content" > "$src"
  dry=1

  run link "$src" "$dst"

  assert_success
  assert_output --partial "Would link"
  [ ! -L "$dst" ]
}

@test "link dry-run does not create parent directories" {
  local src="$TEST_TMPDIR/source.conf"
  local dst="$TEST_TMPDIR/deep/nested/dest.conf"
  echo "content" > "$src"
  dry=1

  run link "$src" "$dst"

  assert_success
  assert_output --partial "Would create directory"
  assert_output --partial "Would link"
  [ ! -d "$TEST_TMPDIR/deep/nested" ]
}

# --- backup() ---

@test "backup creates timestamped backup of existing file" {
  local target="$TEST_TMPDIR/file.conf"
  echo "content" > "$target"

  run backup "$target"

  assert_success
  [ ! -f "$target" ]
  local backup_count
  backup_count=$(find "$TEST_TMPDIR" -maxdepth 1 -name 'file.conf.backup.*' | wc -l)
  [ "$backup_count" -eq 1 ]
}

@test "backup is no-op when target does not exist" {
  run backup "$TEST_TMPDIR/nonexistent"

  assert_success
  assert_output ""
}

@test "backup dry-run does not move file" {
  local target="$TEST_TMPDIR/file.conf"
  echo "content" > "$target"
  dry=1

  run backup "$target"

  assert_success
  assert_output --partial "Would backup"
  [ -f "$target" ]
}

@test "backup handles symlinks" {
  local real="$TEST_TMPDIR/real.conf"
  local link="$TEST_TMPDIR/link.conf"
  echo "content" > "$real"
  ln -s "$real" "$link"

  run backup "$link"

  assert_success
  [ ! -L "$link" ]
}

# --- link_home() ---

@test "link_home creates symlink in HOME as dotfile" {
  local src="$TEST_TMPDIR/gitconfig"
  echo "content" > "$src"

  run link_home "$src" "gitconfig"

  assert_success
  [ -L "$HOME/.gitconfig" ]
  [ "$(readlink "$HOME/.gitconfig")" = "$src" ]
}

# --- link_config() ---

@test "link_config creates symlink in HOME/.config" {
  local src="$TEST_TMPDIR/nvim"
  mkdir -p "$src"

  run link_config "$src" "nvim"

  assert_success
  [ -L "$HOME/.config/nvim" ]
  [ "$(readlink "$HOME/.config/nvim")" = "$src" ]
}

# --- log functions ---

@test "log outputs message in normal mode" {
  dry=0
  run log "hello world"

  assert_success
  assert_output --partial "hello world"
}

@test "log prefixes with DRY RUN in dry mode" {
  dry=1
  run log "hello world"

  assert_success
  assert_output --partial "DRY RUN"
  assert_output --partial "hello world"
}

@test "info outputs with info prefix" {
  run info "some info"

  assert_success
  assert_output --partial "some info"
}

@test "success outputs with OK prefix" {
  run success "done"

  assert_success
  assert_output --partial "OK"
  assert_output --partial "done"
}

@test "fail outputs with FAIL prefix" {
  run fail "broken"

  assert_success
  assert_output --partial "FAIL"
  assert_output --partial "broken"
}
