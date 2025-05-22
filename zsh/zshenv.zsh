autoload -Uz colors && colors

export DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"
export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"

if [ -f "${DOTFILES}/local/zsh/zshenv.zsh" ]; then
    source "${DOTFILES}/local/zsh/zshenv.zsh"
fi

source "${DOTFILES}/zsh/path.zsh"

if [[ "$OSTYPE" == darwin* ]]; then
    export HOMEBREW_NO_ANALYTICS=1
    export BROWSER='open'
fi

export EDITOR='emacs'
export VISUAL='emacs'
export PAGER='less -FgMRXi'

if [[ -z "$LANG" ]]; then
    export LANG='en_US.UTF-8'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

if [[ ! -d "$TMPDIR" ]]; then
    export TMPDIR="/tmp/$LOGNAME"
    mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

if [ -f "${HOME}/.cargo/env" ]; then
    source "${HOME}/.cargo/env"
fi

if [ -d "${HOME}/.nvm" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi

if type rbenv > /dev/null ; then
    eval "$(rbenv init -)"
fi
