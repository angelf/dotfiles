. ~/.zsh/config
. ~/.zsh/aliases
. ~/.zsh/completion
. ~/.bash/env

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && .  ~/.localrc
