alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

# slightly quicker jump up levels in ZSH
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'

alias cat='bat'
alias ping='prettyping --nolegend'
alias top="sudo htop" # alias top and fix high sierra bug

eb-ssh-staging () { eb ssh $(eb list | grep staging | sed  "s/\*//") ; }
eb-ssh-production () { eb ssh $(eb list | grep production | sed  "s/\*//") ; }
eb-ssh-tunnel-to-db-production () { eb ssh $(eb list | grep staging | sed  "s/\*//") --custom 'ssh -i ~/.ssh/aws-eb   -N -L "${ON_PRODUCTION_DB_URI}"' ; }
eb-ssh-tunnel-to-db-staging () { eb ssh $(eb list | grep staging | sed  "s/\*//") --custom 'ssh -i ~/.ssh/aws-eb   -N -L "${ON_STAGING_DB_URI}"' ; }
