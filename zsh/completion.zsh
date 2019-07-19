# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# SSH-Agent client set up
zstyle :omz:plugins:ssh-agent agent-forwarding on

# Setup for Z
. `brew --prefix`/etc/profile.d/z.sh
