typeset -g _theme_crossout='✘'
typeset -g _theme_checkmark='✓'

typeset -g _theme_vcs_unstaged='±'
typeset -g _theme_vcs_staged='+'
typeset -g _theme_vcs_branch=''
typeset -g _theme_vcs_detached='➦'
typeset -g _theme_vcs_cross='✘'

typeset -g _theme_vcs_ahead='↑'
typeset -g _theme_vcs_behind='↓'

typeset -g _theme_user_root='#'
typeset -g _theme_user_other='λ'

typeset -g _theme_preexec_time=$EPOCHREALTIME

typeset -g _theme_timezone="${_theme_timezone:-America/Los_Angeles}"

typeset -g _theme_prev_exit_code=0

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

function _theme-preexec() {
    _theme_preexec_time=${EPOCHREALTIME}
    theme run-segment pre-exec
}

function _theme-precmd() {
    _theme_prev_exit_code=$?
    vcs_info
    theme run-segment pre-cmd
}

add-zsh-hook preexec _theme-preexec
add-zsh-hook precmd _theme-precmd
