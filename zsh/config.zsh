export TERM="xterm-256color"
export ZSH_DISABLE_COMPFIX=true
export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

ZSH_THEME="bullet-train"
BULLETTRAIN_PROMPT_ORDER=( dir git nvm ruby )
BULLETTRAIN_PROMPT_ADD_NEWLINE=true
BULLETTRAIN_PROMPT_SEPARATE_LINE=true
BULLETTRAIN_RUBY_BG=default
BULLETTRAIN_DIR_EXTENDED=0
BULLETTRAIN_NVM_BG=default
BULLETTRAIN_RUBY_PREFIX='\ue21e'
BULLETTRAIN_NVM_PREFIX='\ue718'

fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($ZSH/functions $fpath)

autoload -U $ZSH/functions/*(:t)

HIST_STAMPS="dd/mm/yyyy"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Setup for Z
. `brew --prefix`/etc/profile.d/z.sh

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt NO_SHARE_HISTORY
unsetopt SHARE_HISTORY

setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Nodeenv setup
eval "$(nodenv init -)"
