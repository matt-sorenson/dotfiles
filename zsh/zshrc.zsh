# on macOS /etc/zprofile stomps on the path. Clean it back up.
source "${DOTFILES}/zsh/path.zsh"

AT_WORK=$([[ -f "${DOTFILES}/local/is-work" ]] && echo 1 || echo 0)

if [ -f "${DOTFILES}/local/zsh/zshrc.zsh" ]; then
    source "${DOTFILES}/local/zsh/zshrc.zsh"
fi

source "${DOTFILES}/zsh/update.zsh"

if [ -f "${HOME}/.zprezto/init.zsh" ]; then
    source "${HOME}/.zprezto/init.zsh"
fi

source "${DOTFILES}/zsh/aliases.zsh"

if [ -d "${HOME}/.nvm" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
setopt extended_history         # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first   # Expire a duplicate event first when trimming history.
setopt hist_reduce_blanks       # Remove superfluous blanks from each command line being added to the history list.
setopt hist_ignore_dups         # Do not record an event that was just recorded again.
setopt hist_find_no_dups        # Do not display a previously found event.
setopt hist_verify              # For multiline history don’t execute the line directly; instead, perform history expansion and reload the line into the editing buffer.
setopt share_history            # Share history between all sessions.
setopt inc_append_history_time  # Append to history file instead of replacing it.

# Directory stack options
setopt auto_pushd           # treat cd as pushd allowing popd to go back to previous directory
setopt auto_cd              # If provided a valid directory and no command treat it as cd
setopt pushd_to_home        # Push to home when no directories in stack

unsetopt pushd_silent       # Print the new directory stack after pushd or popd.

# Random settings
setopt complete_in_word     # Leave cursor when using completions
setopt extended_glob        # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc. (An initial unquoted ‘~’ always produces named directory expansion.)
setopt interactive_comments # treat comments as comments in interactive shell
setopt clobber              # Allow `>` to truncate files
setopt multios              # Perform implicit tees or cats when multiple redirections are attempted

unsetopt beep               # Disable 'pc speaker' beep

auto-check-for-update

ssh-add --apple-load-keychain

prompt ender

if type rbenv > /dev/null ; then
    eval "$(rbenv init -)"
fi

if type direnv > /dev/null ; then
    eval "$(direnv hook zsh)"
fi

bindkey -e

compinit -i

if [ -f "${HOME}/.fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "${HOME}/.fzf-tab/fzf-tab.plugin.zsh"
fi

if [ -f "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
