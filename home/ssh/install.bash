#!/usr/bin/env bash
#
# ssh/install.bash - Generate SSH key if absent
#
# Many later scripts depend on ~/.ssh/id_ed25519 existing:
#   - home/git/install.bash skips signingkey + allowed_signers if absent
#   - GitHub HTTPS git operations rely on gh credential helper
#   - 1Password SSH agent auth requires a key in the OS keychain
#
# Idempotent: skips if a key already exists.

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
  success "SSH key already exists at $SSH_KEY"
  return 0 2>/dev/null || exit 0
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

git_email=""
if [[ -f "$HOME/.gitconfig.local" ]]; then
  git_email=$(git config --file "$HOME/.gitconfig.local" user.email 2>/dev/null || true)
fi

if [[ -z "$git_email" ]]; then
  echo ""
  user "What email should be used for the SSH key comment?"
  read -r -e git_email
fi

info "Generating ed25519 SSH key for $git_email..."
ssh-keygen -t ed25519 -C "$git_email" -f "$SSH_KEY" -N ""

if [[ "$(uname -s)" == "Darwin" ]]; then
  info "Adding key to macOS keychain..."
  ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || \
    info "ssh-agent not running yet — key will load on next shell login"
fi

success "SSH key generated"
echo ""
info "Public key (add this to GitHub):"
cat "${SSH_KEY}.pub"
echo ""
user "Add the key at: https://github.com/settings/ssh/new"
echo ""
