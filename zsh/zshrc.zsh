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
setopt append_history
setopt hist_expire_dups_first
setopt hist_reduce_blanks
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify

setopt interactive_comments # treat comments as comments in interactive shell
setopt auto_pushd
setopt auto_cd
setopt complete_inword
setopt no_beep

prompt ender

# if not in a tmux session prompt to start one
if [ "$TMUX" = "" ]; then
    tmux attach;

    if [ 0 -ne $? ]; then
        read -q "LAUNCH_TMUX?launch tmux? "
        if [ 'y' = "$LAUNCH_TMUX" ]; then
           tmux
        fi
        unset LAUNCH_TMUX
    fi
fi

compinit
