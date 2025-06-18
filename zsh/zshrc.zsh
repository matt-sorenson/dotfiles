ZSH_COMPDUMP="${DOTFILES}/tmp/zsh-compdump-${ZSH_VERSION}"
zstyle ':completion::complete:*' cache-path "${DOTFILES}/tmp/zsh-compcache"

autoload -U compinit && compinit -d "${ZSH_COMPDUMP}"

if [[ -f "${HOME}/.zcompdump" ]]; then
    print-header -w "Removing old zcompdump file."
    rm -f "${HOME}/.zcompdump"
fi

# on macOS /etc/zprofile stomps on the path. Clean it back up.
source "${DOTFILES}/zsh/path.zsh"

export AT_WORK=0
if [[ -f "${DOTFILES}/local/is-work" ]]; then
    AT_WORK=1
fi

if [[ -r "${DOTFILES}/local/zsh/zshrc.zsh" ]]; then
    source "${DOTFILES}/local/zsh/zshrc.zsh"
fi

source "${DOTFILES}/zsh/aliases.zsh"

# These are only in zshrc and not path.zsh as they shouldn't be set for non-interactive shells
add-to-fpath "${DOTFILES}/zsh/completions"
add-to-fpath "${DOTFILES}/local/zsh/completions"

if [[ "${OSTYPE}" == darwin* ]]; then
    # this file may have been recreated by brew updates.
    if [[ -e /opt/homebrew/share/zsh/site-functions/_git ]]; then
        print-header cyan "removing /opt/homebrew/share/zsh/site-functions/_git"
        print "this is the git autocomplete provided by git, deleting this to" \
            "fallback to the one provided by zsh"
        rm -f /opt/homebrew/share/zsh/site-functions/_git
    fi

    # Disable Apple's "save/restore shell state" feature.
    SHELL_SESSIONS_DISABLE=1

    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced

    ssh-add --apple-load-keychain
fi

# Autocomplete will complete past '-'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}'

LESSHISTFILE="${DOTFILES}/tmp/less-history" # Disable less history file

# History settings
HISTFILE="${DOTFILES}/tmp/zsh-history"
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

# when a trap is set in a function it will be restored when the function exits.
setopt local_traps
setopt local_options

# Random settings
setopt complete_in_word     # Leave cursor when using completions
setopt extended_glob        # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc. (An initial unquoted ‘~’ always produces named directory expansion.)
setopt interactive_comments # treat comments as comments in interactive shell
setopt clobber              # Allow `>` to truncate files
setopt multios              # Perform implicit tees or cats when multiple redirections are attempted

unsetopt beep               # Disable "pc speaker" beep

dot-check-for-update --auto 15 # check for updates every 15 hours

bindkey -e

if [[ -d "${HOME}/.nvm" ]]; then
    # This loads nvm bash_completion
    [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"
fi

if [[ -r "${DOTFILES}/deps/fzf-tab/fzf-tab.plugin.zsh" ]]; then
    # Don't sort the completions for aws-signon (keep them in dev, staging, prod order)
    zstyle ':completion:*:aws-signon:*' sort false

    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    source "${DOTFILES}/deps/fzf-tab/fzf-tab.plugin.zsh"
fi

compinit -d "${ZSH_COMPDUMP}"

# This has some arrays/maps that are used for auto-completion
source "${DOTFILES}/zsh/completion-helper.zsh"

if [[ -r "${DOTFILES}/deps/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "${DOTFILES}/deps/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

source "${DOTFILES}/zsh/ender.zsh-theme"
