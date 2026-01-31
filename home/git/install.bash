#!/usr/bin/env bash
#
# git/install.bash - Set up git configuration
#
# Creates gitconfig.local with user-specific settings (name, email)
# if it doesn't already exist.

GITCONFIG_LOCAL="$HOME/.gitconfig.local"

# Skip if gitconfig.local already exists
if [[ -f "$GITCONFIG_LOCAL" ]]; then
  success "gitconfig.local already exists"
  return 0
fi

info "Setting up git author configuration..."

# Determine credential helper based on OS
git_credential='cache'
if [[ "$(uname -s)" == "Darwin" ]]; then
  git_credential='osxkeychain'
fi

# Prompt for git author details
echo ""
echo "  What is your git author name?"
read -r -e git_authorname

echo "  What is your git author email?"
read -r -e git_authoremail

# Create gitconfig.local from template
cat > "$GITCONFIG_LOCAL" <<EOF
[user]
    name = $git_authorname
    email = $git_authoremail
[credential]
    helper = $git_credential
EOF

success "Created $GITCONFIG_LOCAL"
