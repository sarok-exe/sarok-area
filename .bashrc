PS1='[\u@\h \W]\$ '

export CAELESTIA_VIRTUAL_ENV="/home/sarok/.local/state/quickshell/.venv"

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo pacman -Syu'
alias ssync='~/Documents/Scripts/sync_configs.sh'

eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(thefuck --alias)"
