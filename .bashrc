#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ytdl='yt-dlp'
alias pictopress='~/projects/pictopress/pictopress.sh'
alias hp='httpplanner'           # shortcut: hp → httpplanner TUI
alias foc='daily-focus'

alias rmimg='find ~/projects/sarok-archive -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" -o -name "*.ico" -o -name "*.bmp" \) -delete'
pushaps() { git add . && git commit -m "$*" && git push; }
PS1='[\u@\h \W]\$ '

export PATH=$PATH:/home/sarok/scripts

# opencode
export PATH=/home/sarok/.opencode/bin:$PATH

# AI Icon Sorter
alias ai='~/projects/z-ai/ai'
# وظيفة لتشغيل الكاميرا بإعدادات محسنة وسلاسة عالية
cam-start() {
    v4l2-ctl -d /dev/video0 --set-ctrl=sharpness=4
    v4l2-ctl -d /dev/video0 --set-ctrl=brightness=5
    v4l2-ctl -d /dev/video0 --set-ctrl=saturation=80

    # تشغيل الكاميرا في نافذة صغيرة، بدون إطارات، وفوق كل النوافذ
    mpv --demuxer-lavf-format=video4linux2 \
        --demuxer-lavf-o-set=input_format=mjpeg \
        --profile=low-latency --untimed \
        --ontop --no-border \
        --geometry=320x180-10-10 \
        av://v4l2:/dev/video0
}
alias clean='sudo ~/.config/Scripts/clean_net.sh'

# FlashFinance: gold trading signal advisor (entry/exit zones, technicals, news)
flashfinance() {
    GROQ_API_KEY=gsk_your-key-here ~/projects/FlashFinance/venv/bin/flashfinance "$@"
}
# Starship prompt
eval "$(starship init bash)"

# Created by `pipx` on 2026-05-08 19:19:47
export PATH="$PATH:/home/sarok/.local/bin"

export PATH=$PATH:/home/sarok/.spicetify


# growner: interactive link processor (defaults to links.txt)
grown() {
    python3 ~/projects/growner/growner.py "${1:-links.txt}"
}

# timekpr: check remaining computer time today

# timekpr: check remaining computer time today
timer() {
    sudo timekpra --getuserinfort 'sarok' 2>/dev/null | python3 -c "
import sys
for line in sys.stdin.read().split('\n'):
    if 'TIME_LEFT_DAY' in line and 'ACTUAL_' not in line:
        secs = int(line.split(': ')[1])
        h, m = divmod(secs, 3600); m //= 60
        print(f'⏱ {h}h {m}m remaining today')
    elif 'TIME_SPENT_DAY' in line and 'ACTUAL_' not in line:
        secs = int(line.split(': ')[1])
        h, m = divmod(secs, 3600); m //= 60
        print(f'   {h}h {m}m used today')
"
}

# zoxide: smart directory jumper (z)
eval "$(zoxide init bash)"
