# Link git configuration files to home directory
link_home "$HOME_DIR/git/gitconfig" "gitconfig"
link_home "$HOME_DIR/git/gitignore" "gitignore"

# Link local gitconfig if it exists
if [[ -f "$HOME_DIR/git/gitconfig.local" ]]; then
  link_home "$HOME_DIR/git/gitconfig.local" "gitconfig.local"
fi
