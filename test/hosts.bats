#!/usr/bin/env bats
#
# Contract tests for host configs and package structure

load helpers/setup

HOSTS_DIR="$REPO_ROOT/hosts"
HOME_DIR="$REPO_ROOT/home"

@test "every host config exports SYSTEM" {
  for host_file in "$HOSTS_DIR"/*.bash; do
    [ -f "$host_file" ] || continue
    local host_name
    host_name=$(basename "$host_file")

    # Source in a subshell to avoid polluting the test environment
    run bash -c "source '$host_file' && [ -n \"\$SYSTEM\" ]"
    if [ "$status" -ne 0 ]; then
      echo "SYSTEM not exported in: $host_name" >&2
      return 1
    fi
  done
}

@test "every host config exports non-empty PACKAGES array" {
  for host_file in "$HOSTS_DIR"/*.bash; do
    [ -f "$host_file" ] || continue
    local host_name
    host_name=$(basename "$host_file")

    run bash -c "source '$host_file' && [ \${#PACKAGES[@]} -gt 0 ]"
    if [ "$status" -ne 0 ]; then
      echo "PACKAGES empty or missing in: $host_name" >&2
      return 1
    fi
  done
}

@test "every package in PACKAGES has a directory under home/" {
  for host_file in "$HOSTS_DIR"/*.bash; do
    [ -f "$host_file" ] || continue
    local host_name
    host_name=$(basename "$host_file")

    # Extract PACKAGES array values
    local packages
    packages=$(bash -c "source '$host_file' && printf '%s\n' \"\${PACKAGES[@]}\"")

    while IFS= read -r pkg; do
      [ -z "$pkg" ] && continue
      if [ ! -d "$HOME_DIR/$pkg" ]; then
        echo "Package directory missing: home/$pkg (referenced in $host_name)" >&2
        return 1
      fi
    done <<< "$packages"
  done
}

@test "every link.bash is valid bash syntax" {
  for link_script in "$HOME_DIR"/*/link.bash; do
    [ -f "$link_script" ] || continue
    local pkg_name
    pkg_name=$(basename "$(dirname "$link_script")")

    run bash -n "$link_script"
    if [ "$status" -ne 0 ]; then
      echo "Syntax error in: home/$pkg_name/link.bash" >&2
      echo "$output" >&2
      return 1
    fi
  done
}

@test "every install.bash is valid bash syntax" {
  local found=0
  for install_script in "$HOME_DIR"/*/install.bash; do
    [ -f "$install_script" ] || continue
    found=1
    local pkg_name
    pkg_name=$(basename "$(dirname "$install_script")")

    run bash -n "$install_script"
    if [ "$status" -ne 0 ]; then
      echo "Syntax error in: home/$pkg_name/install.bash" >&2
      echo "$output" >&2
      return 1
    fi
  done

  # Skip test if no install scripts exist
  if [ "$found" -eq 0 ]; then
    skip "No install.bash scripts found"
  fi
}
