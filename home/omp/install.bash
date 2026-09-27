#!/usr/bin/env bash
#
# omp/install.bash - Install the superpowers plugin into omp
#
# opencode loads superpowers straight from github.com/obra/superpowers. omp
# installs it from the marketplace catalog in that same repo. Plugin state
# lives in ~/.omp/plugins, outside the dotfiles.
#
# Idempotent: skips when omp is missing or the plugin is already installed.

if ! command -v omp &>/dev/null; then
  info "omp not on PATH yet — skipping superpowers. Re-run script/run after brew bundle."
  return 0 2>/dev/null || exit 0
fi

if omp plugin list 2>/dev/null | grep -q "superpowers@superpowers-dev"; then
  success "omp superpowers plugin already installed"
  return 0 2>/dev/null || exit 0
fi

if ! omp plugin marketplace list 2>/dev/null | grep -q "superpowers"; then
  omp plugin marketplace add obra/superpowers &>/dev/null \
    || fail "omp marketplace add failed — run 'omp plugin marketplace add obra/superpowers'"
fi

info "Installing superpowers into omp..."
if omp plugin install superpowers@superpowers-dev &>/dev/null; then
  success "omp superpowers plugin installed"
else
  fail "omp superpowers install failed — run 'omp plugin install superpowers@superpowers-dev'"
fi
