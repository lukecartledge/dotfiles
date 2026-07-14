alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

alias cat='bat'
alias ping='prettyping --nolegend'
alias top="sudo htop" # alias top and fix high sierra bug

alias sub='subl'

# opencode: lean local launch — skips OMO + plugins (--pure), routes to local Ollama qwen3.
# For offline/privacy work or saving work-token allowance. Normal `opencode` stays OMO+Copilot.
alias opencode-local='opencode --pure -m ollama/qwen3:30b-a3b'
