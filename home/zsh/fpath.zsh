# Add functions directory to fpath for custom zsh functions and completions
if [[ -d "$DOTFILES/home/functions/zsh-functions" ]]; then
  fpath=("$DOTFILES/home/functions/zsh-functions" $fpath)
fi
