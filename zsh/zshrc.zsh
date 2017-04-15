prompt-security-str() {}

# on macOS /etc/zprofile stomps on the path. Clean it back up.
if [ -f "${DOTFILES}/zsh/path.zsh" ]; then
    source "${DOTFILES}/zsh/path.zsh"
fi

export WORKSPACE_ROOT_DIR="$HOME/ws"
export AT_WORK=0

if [ -f "$DOTFILES/local/zsh/zshrc.zsh" ]; then
    source "$DOTFILES/local/zsh/zshrc.zsh";
fi

source "${HOME}/.zprezto/init.zsh"

source "$DOTFILES/zsh/aliases.zsh";

if [ -d "$DOTFILES/zsh/completion" ]; then
    fpath=("$DOTFILES/zsh/completion" $fpath)
fi

COMPLETION_WAITING_DOTS="true"

# History settings
HIST_STAMPS="yyyy-mm-dd"
HISTFILE="$HOME/.dotfiles/tmp/history"
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

prompt ender

# if not in a tmux session prompt to start one
if [[ "${TMUX}" = "" && "${TERM}" != "screen" ]]; then
    tmux attach;

    if [ 0 -ne $? ]; then
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

if [[ "${OSTYPE}" =~ "darwin" ]]; then
    # Add ssh keys from keychain on macOS
    ssh-add -A
else
    ssh-add
fi

compinit
