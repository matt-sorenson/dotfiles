# on macOS /etc/zprofile stomps on the path. Clean it back up.
source "${DOTFILES}/zsh/path.zsh"

WORKSPACE_ROOT_DIR="$HOME/ws"
AT_WORK=0

if [ -f "$DOTFILES/local/zsh/zshrc.zsh" ]; then
    source "$DOTFILES/local/zsh/zshrc.zsh"
fi

source "${DOTFILES}/zsh/update.zsh"

source "${HOME}/.zprezto/init.zsh"

source "${DOTFILES}/zsh/aliases.zsh"

if [ -d "$HOME/.nvm" ]
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi

if [ -d "${DOTFILES}/zsh/completion" ]; then
    fpath=("${DOTFILES}/zsh/completion" $fpath)
fi

if [[ "$OSTYPE" == darwin* ]]; then
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
fi

COMPLETION_WAITING_DOTS="true"
# Autocomplete will complete past '-'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}'

# History settings
HISTFILE="${DOTFILES}/tmp/history"
HISTSIZE=101000
SAVEHIST=100000
setopt hist_expire_dups_first
setopt hist_reduce_blanks
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify
setopt share_history
setopt no_append_history

# Directory stack options
setopt auto_pushd
setopt auto_cd
setopt pushd_to_home
setopt no_pushd_silent

# Random settings
setopt complete_inword
setopt extended_glob
setopt interactive_comments # treat comments as comments in interactive shell
setopt no_beep
setopt clobber
setopt multios

auto-check-for-update

# if not in a tmux session prompt to start one
if [[ "${TMUX}" = "" && "${TERM}" != "screen" ]]; then
    if ! tmux attach; then
        if [ -v PROMPT_FOR_TMUX ]; then
            read -q "LAUNCH_TMUX?launch tmux? "
            if [ 'y' = "$LAUNCH_TMUX" ]; then
               tmux
               exit
            fi
            unset LAUNCH_TMUX
        else
            tmux
        fi
    fi
fi

ssh-add
prompt ender

if which rbenv; then
    eval "$(rbenv init -)"
fi

if [ -d "${HOME}/.cargo" ]; then
    source ${HOME}/.cargo/env
fi

compinit

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
