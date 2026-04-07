# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Create a stable symlink to 1Password's SSH agent socket so GUI apps
# (e.g. Obsidian) can use a fixed, username-independent path.
if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
  ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.ssh/ssh_auth_sock
fi
