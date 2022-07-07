alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

# slightly quicker jump up levels in ZSH
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'

alias cat='bat'
alias ping='prettyping --nolegend'
alias top="sudo htop" # alias top and fix high sierra bug

eb-ssh-staging () { eb ssh $(eb list | rg staging | sed  "s/\*//") ; }
eb-ssh-production () { eb ssh $(eb list | rg production | sed  "s/\*//") ; }

alias on-ngrok-applepay='ngrok http 3001 -subdomain on-dev-applepay'
alias on-test-applepay='HOST=on-dev-applepay.ngrok.io LOCAL_TEST=true gulp --no-reload'

# Helpful on an M1 Mac
# Use to install in brew as if in x86 environment
alias brew86="arch -x86_64 /usr/local/bin/brew"
# Run any command in x86 environment through Rosetta
alias leg="arch -x86_64 $@"

alias sub='subl'
