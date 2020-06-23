# colorls overides for ls
#   `gem install colorls`
# Needs to be done for each version of Ruby running
if $(colorls &>/dev/null)
then
  alias ls="colorls -h --group-directories-first -1"
  alias l="colorls --group-directories-first --almost-all"
  alias ll="colorls --group-directories-first --almost-all -l"
  alias la="colorls --group-directories-first"
fi
