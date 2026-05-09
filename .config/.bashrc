#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ytdl='yt-dlp'
PS1='[\u@\h \W]\$ '

# opencode
export PATH=/home/sarok/.opencode/bin:$PATH
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

# Starship prompt
eval "$(starship init bash)"

# Created by `pipx` on 2026-05-08 19:19:47
export PATH="$PATH:/home/sarok/.local/bin"

export PATH=$PATH:/home/sarok/.spicetify
