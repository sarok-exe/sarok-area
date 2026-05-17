
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/bash_profile.pre.bash"

#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Created by `pipx` on 2026-05-08 19:19:47
export PATH="$PATH:/home/sarok/.local/bin"

export PATH=$PATH:/home/sarok/.spicetify


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/bash_profile.post.bash"
