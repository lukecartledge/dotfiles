# Prompt comes from starship (see zshrc); an empty theme stops oh-my-zsh
# from installing one of its own. To revert, set:
#   ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME=""

# Skip oh-my-zsh's auto-update check on every startup. Update manually with `omz update`.
zstyle ':omz:update' mode disabled

plugins=(
  bundler
  colored-man-pages
  direnv
  git
  gpg-agent
  rake
  rails
  ruby
  ssh-agent
  zsh-autosuggestions
  zsh-syntax-highlighting
)
