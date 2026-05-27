if [[ "$(uname -s)" != "Darwin" ]]; then
  return 0
fi

mkdir -p "$HOME/.config/ghostty"
link "$HOME_DIR/ghostty/config" "$HOME/.config/ghostty/config"
