autoload -Uz colors && colors

export DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"
export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"

if [[ -r "${DOTFILES}/local/zsh/zshenv.zsh" ]]; then
    source "${DOTFILES}/local/zsh/zshenv.zsh"
fi

source "${DOTFILES}/zsh/path.zsh"

if [[ "${OSTYPE}" == darwin* ]]; then
    export HOMEBREW_NO_ANALYTICS=1
    export BROWSER='open'

    if ! command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
    fi
fi

if command -v emacs &> /dev/null; then
    export EDITOR='emacs'
    export VISUAL='emacs'
fi

export PAGER='less -FgMRXi'

export LANG="${LANG:-en_US.UTF-8}"

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
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

# Lazy load nvm to speed up shell startup time, though the first call to
# npm/node/nvm/pnpm/npx will be slower.
if [[ -d "${HOME}/.nvm" ]]; then
    _lazy_load_nvm() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        unset -f corepack npm node nvm pnpm npx _lazy_load_nvm
        export NVM_DIR="${HOME}/.nvm"
        [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
    }

    npm() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        npm $@
    }

    npx() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        npx $@
    }

    node() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        node $@
    }

    nvm() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        nvm $@
    }

    corepack() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        corepack $@
    }

    pnpm() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        _lazy_load_nvm
        pnpm $@
    }
fi

if command -v rbenv > /dev/null ; then
    eval "$(rbenv init -)"
fi

autoload \
    aws-signon \
    print-header \
    repoman
