zmodload zsh/datetime
ZSHENV_START_TIME=$EPOCHREALTIME

setopt warn_create_global # Be annoying about setting global variables

# These are global variables that are created by VSCode integration but aren't
# marked as global so 'warn_create_global' complains about them.
typeset -g __vsc_prior_prompt
typeset -g __vsc_prior_prompt2

typeset -gA dotfiles_completion_functions=()

if [[ "${OSTYPE}" == darwin* ]]; then
    is-macos() {
        return 0
    }

    is-linux() {
        return 1
    }

    export BROWSER='open'
elif [[ "${OSTYPE}" == *linux* ]]; then
    is-macos() {
        return 1
    }

    is-linux() {
        return 0
    }

    # Debian likes to call compinit with...
    skip_global_compinit=1
fi

if [[ "$(uname -r)" == *microsoft-standard* ]]; then
    is-wsl() {
        return 0
    }
else
    is-wsl() {
        return 1
    }
fi

if ! command -v compdef &> /dev/null; then
    typeset -g _dot_compdef_function=1
    compdef() {
        if (( $# != 2)); then
            print-header -e "compdef: Expected 2 arguments, got $#"
            return 1
        fi

        dotfiles_completion_functions[$2]="$1"
    }
fi

autoload -Uz colors && colors

export LANG=en_US.UTF-8
export DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"
export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"

ssource() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        print-header -e "Usage: source <file>

    Source a file if it exists and is readable."
    elif [[ -r "$1" ]]; then
        source "$1"
    fi
}

ssource "${DOTFILES}/local/zsh/zshenv.zsh"

source "${DOTFILES}/zsh/path.zsh"
source "${DOTFILES}/zsh/zshenv/nvm.zsh"
source "${DOTFILES}/zsh/zshenv/aliases.zsh"

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

export PAGER='less -FgMRXiS'

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

ssource "${HOME}/.cargo/env"

if command -v rbenv > /dev/null ; then
    eval "$(rbenv init -)"
fi

dot-autoload-dir-files() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    if [[ -d "$1" ]]; then
        add-to-fpath "$1"

        local file
        for file in "$1"*(.N); do
            autoload -z "${file:t}"
        done
    fi
}

dot-autoload-dir-files "${DOTFILES}/zsh/functions/env/"
dot-autoload-dir-files "${DOTFILES}/zsh/functions/"
dot-autoload-dir-files "${DOTFILES}/local/zsh/functions/"

if is-wsl && command -v ws &> /dev/null; then
    wsl-clone() {
        ws clone --cmd-name 'wsl-clone' --root "${WSL_WORKSPACE_ROOT_DIR}" --soft-line "${WORKSPACE_ROOT_DIR}" "$@"
    }

    # Because [wsl-clone] has the '-' in it we use this strange syntax...
    typeset 'dotfiles_completion_functions[wsl-clone]'='_ws-clone'
fi
