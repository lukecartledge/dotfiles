#!/usr/bin/env bash
#
# git/install.bash - Set up git configuration and SSH commit signing
#
# Creates gitconfig.local with user-specific settings (name, email, signingkey)
# and generates ~/.ssh/allowed_signers for commit signature verification.

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"
SSH_PUBKEY="$HOME/.ssh/id_ed25519.pub"

if [[ -f "$GITCONFIG_LOCAL" ]]; then
  success "gitconfig.local already exists"
else
  info "Setting up git author configuration..."

  git_credential='cache'
  if [[ "$(uname -s)" == "Darwin" ]]; then
    git_credential='osxkeychain'
  fi

  echo ""
  echo "  What is your git author name?"
  read -r -e git_authorname

  echo "  What is your git author email?"
  read -r -e git_authoremail

  git_signingkey=""
  if [[ -f "$SSH_PUBKEY" ]]; then
    git_signingkey=$(cat "$SSH_PUBKEY")
    info "Found SSH public key for commit signing"
  else
    info "No SSH key found at $SSH_PUBKEY — skipping signingkey"
  fi

  cat > "$GITCONFIG_LOCAL" <<EOF
[user]
    name = $git_authorname
    email = $git_authoremail
EOF

  if [[ -n "$git_signingkey" ]]; then
    cat >> "$GITCONFIG_LOCAL" <<EOF
    signingkey = $git_signingkey
EOF
  fi

  cat >> "$GITCONFIG_LOCAL" <<EOF
[credential]
    helper = $git_credential
EOF

  success "Created $GITCONFIG_LOCAL"
fi

if [[ -f "$ALLOWED_SIGNERS" ]]; then
  success "allowed_signers already exists"
  return 0
fi

if [[ ! -f "$SSH_PUBKEY" ]]; then
  info "No SSH key at $SSH_PUBKEY — skipping allowed_signers"
  return 0
fi

git_email=$(git config --file "$GITCONFIG_LOCAL" user.email 2>/dev/null)
if [[ -z "$git_email" ]]; then
  info "No email in gitconfig.local — skipping allowed_signers"
  return 0
fi

mkdir -p "$HOME/.ssh"
echo "$git_email $(cat "$SSH_PUBKEY")" > "$ALLOWED_SIGNERS"
success "Created $ALLOWED_SIGNERS"
