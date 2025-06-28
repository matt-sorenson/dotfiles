autoload -Uz colors && colors

export LANG=en_US.UTF-8
export DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"
export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"

if [[ -r "${DOTFILES}/local/zsh/zshenv.zsh" ]]; then
    source "${DOTFILES}/local/zsh/zshenv.zsh"
fi

source "${DOTFILES}/zsh/path.zsh"
source "${DOTFILES}/zsh/zshenv.nvm.zsh"

if [[ "${OSTYPE}" == darwin* ]]; then
    export BROWSER='open'
elif [[ "${OSTYPE}" == *linux* ]]; then
    # Debian likes to call compinit with...
    skip_global_compinit=1
fi

if command -v brew &> /dev/null; then
    export HOMEBREW_NO_ANALYTICS=1
    eval "$(brew shellenv)"
fi

if command -v emacs &> /dev/null; then
    export VISUAL='emacs'
elif command -v nvim &> /dev/null; then
    export VISUAL='nvim'
elif command -v vim &> /dev/null; then
    export VISUAL='vim'
fi

export PAGER='less -FgMRXi'

# lesspipe can read certain binary files and show useful data instead of gibberish
if command -v lesspipe.sh &> /dev/null; then
    eval "$(lesspipe.sh)"
elif command -v lesspipe &> /dev/null; then
    eval "$(lesspipe)"
fi

if [[ -z "${TMPDIR}" ]]; then
    export TMPDIR="/tmp/$LOGNAME"
fi
if [[ ! -d "${TMPDIR}" ]]; then
    mkdir -p -m 700 "${TMPDIR}"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

if [[ -r "${HOME}/.cargo/env" ]]; then
    source "${HOME}/.cargo/env"
fi

if command -v rbenv > /dev/null ; then
    eval "$(rbenv init -)"
fi

exit_trap_emulate_local_function() {
    while (( $# )) do
        if [[ "$(type -w $1)" == *": function" ]]; then
            unset -f "$1"
        fi
        shift
    done
}

is-emoji() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

    local -a exceptions=('❌' '✅')

    if (( ${exceptions[(Ie)$1]} )); then
        return 0
    fi

    local -i codepoint=$(printf '%d' "'$1")

    (( (codepoint >= 0x1F600 && codepoint <= 0x1F64F) ||
        (codepoint >= 0x1F300 && codepoint <= 0x1F5FF) ||
        (codepoint >= 0x1F680 && codepoint <= 0x1F6FF) ||
        (codepoint >= 0x1F900 && codepoint <= 0x1F9FF) ))
}

autoload \
    aws-signon \
    print-header \
    repoman
