# Link herdr configuration to ~/.config/herdr
#
# Only config.toml is linked; herdr keeps its sockets, logs and session state
# in the same directory.

mkdir -p "$HOME/.config/herdr"
link "$HOME_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
