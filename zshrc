. ~/.zsh/aliases
. ~/.zsh/completion
. ~/.zsh/env
. ~/.zsh/config
. ~/.ec2/env

# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && .  ~/.localrc
