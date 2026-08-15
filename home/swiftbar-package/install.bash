#!/usr/bin/env bash

SWIFTBAR_REPOSITORY="${SWIFTBAR_REPOSITORY:-git@github.com:lukecartledge/copilot-quota.git}"
SWIFTBAR_CHECKOUT="${SWIFTBAR_CHECKOUT:-$HOME/code/copilot-quota}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

if [[ -d "$SWIFTBAR_CHECKOUT/.git" ]]; then
  info "SwiftBar checkout available: $SWIFTBAR_CHECKOUT"
  return 0
fi

if [[ -e "$SWIFTBAR_CHECKOUT" ]]; then
  fail "SwiftBar checkout path is not a Git repository: $SWIFTBAR_CHECKOUT"
  return 1
fi

if ! command -v git >/dev/null 2>&1; then
  fail "Git is required to clone the SwiftBar repository"
  return 1
fi

mkdir -p "$(dirname "$SWIFTBAR_CHECKOUT")"
info "Cloning SwiftBar repository to $SWIFTBAR_CHECKOUT"
git clone "$SWIFTBAR_REPOSITORY" "$SWIFTBAR_CHECKOUT"
