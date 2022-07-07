_ARCH=$(arch)
PROMPT="$_ARCH $PROMPT"

export PATH="/opt/homebrew/opt/openssl@1.1/bin:/usr/local/opt/curl/bin:/opt/homebrew/opt/mysql@5.7/bin:/opt/homebrew/opt/mysql-client/bin:$DOTFILES/bin:$PATH"

# Requires iterm2
if [[ "$_ARCH" == "i386" ]]; then
 export ASDF_DATA_DIR="$HOME/.asdf_x86"
 export PATH="/usr/local/homebrew/bin:/usr/local/homebrew/opt:$PATH"
else
 export PATH="/opt/homebrew/bin:/opt/homebrew/opt:$PATH"
fi
# export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
