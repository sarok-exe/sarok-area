PS1='[\u@\h \W]\$ '

export CAELESTIA_VIRTUAL_ENV="/home/sarok/.local/state/quickshell/.venv"
export PATH="$HOME/.opencode/bin:$PATH"
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
alias ff='fastfetch'
alias yt='yt-dlp'


yts() {
    yt-dlp --download-sections "*$1" "$2"
}
record() {
    mkdir -p ~/Videos/Recordings
    local FILENAME="rec_$(date +%Y-%m-%d_%H-%m-%S).mp4"
    local FILEPATH="$HOME/Videos/Recordings/$FILENAME"
    echo "🎥 بدأ التسجيل... اضغط Ctrl+C للإيقاف"
    echo "💾 سيتم الحفظ في: $FILEPATH"
    wf-recorder -f "$FILEPATH"
}

eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(thefuck --alias)"
export PATH="$HOME/.local/bin:$PATH"
