ZSH_COMPDUMP="${DOTFILES}/tmp/zsh-compdump-${ZSH_VERSION}"
zstyle ':completion::complete:*' cache-path "${DOTFILES}/tmp/zsh-compcache"

if [[ -f "${HOME}/.zcompdump" ]]; then
    print-header cyan "Removing old zcompdump file."
    rm "${HOME}/.zcompdump"
fi

typeset -g DOTFILES_ZCOMPILE_FILES=()

# macOS and some other OSs stomp on the path in /etc/zprofile or /etc/profile.
# Clean it back up.
source "${DOTFILES}/zsh/path.zsh"

export AT_WORK=0
if [[ -f "${DOTFILES}/local/is-work" ]]; then
    AT_WORK=1
fi

typeset -A dotfiles_completion_functions=()

if [[ -r "${DOTFILES}/local/zsh/zshrc.zsh" ]]; then
    source "${DOTFILES}/local/zsh/zshrc.zsh"
fi

source "${DOTFILES}/zsh/zshrc.aliases.zsh"

# These are only in zshrc and not path.zsh as they shouldn't be set for non-interactive shells
add-to-fpath "${DOTFILES}/local/zsh/completions"

if [[ "${OSTYPE}" == darwin* ]]; then
    # this file may have been recreated by brew updates.
    if [[ -e /opt/homebrew/share/zsh/site-functions/_git ]]; then
        print-header cyan "removing /opt/homebrew/share/zsh/site-functions/_git"
        print "this is the git autocomplete provided by git, deleting this to" \
            "fallback to the one provided by zsh"
        rm /opt/homebrew/share/zsh/site-functions/_git
    fi

    # Disable Apple's "save/restore shell state" feature.
    SHELL_SESSIONS_DISABLE=1

    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced

    ssh-add --apple-load-keychain
fi

# less
# -F - quit if one screen
# -M - show a detailed prompt at the bottom
# -R - display ANSI color codes and other control characters (raw)
# -i - ignore case when searching
# -X - don't clear the screen on exit
# -N - number lines
export LESS='-NFMRiXN'
export LESSHISTFILE="${DOTFILES}/tmp/less-history"

################################################################################
# History settings
################################################################################
HISTFILE="${DOTFILES}/tmp/zsh-history"
HISTSIZE=101000
SAVEHIST=100000
setopt extended_history        # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first  # Expire a duplicate event first when trimming history.
setopt hist_reduce_blanks      # Remove superfluous blanks from each command line being added to the history list.
setopt hist_ignore_dups        # Do not record an event that was just recorded again.
setopt hist_find_no_dups       # Do not display a previously found event.
setopt hist_verify             # For multiline history don’t execute the line directly; instead, perform history expansion and reload the line into the editing buffer.
setopt share_history           # Share history between all sessions.
setopt inc_append_history_time # Append to history file instead of replacing it.

################################################################################
# cd/pushd/popd/dirs settings
################################################################################
setopt auto_pushd    # treat cd as pushd allowing popd to go back to previous directory
setopt auto_cd       # If provided a valid directory and no command treat it as cd
setopt pushd_to_home # Push to home when no directories in stack
setopt pushd_silent  # Print the new directory stack after pushd or popd.

# when a trap is set in a function it will be restored when the function exits.
setopt local_traps
setopt local_options

# Random settings
setopt complete_in_word     # Leave cursor when using completions
setopt extended_glob        # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc. (An initial unquoted ‘~’ always produces named directory expansion.)
setopt interactive_comments # treat comments as comments in interactive shell
setopt clobber              # Allow `>` to truncate files
setopt multios              # Perform implicit tees or cats when multiple redirections are attempted
# This isn't enabled by default because it can cause issues with some commands
# setopt null_glob             # If no matches are found, return an empty string instead of the pattern.

unsetopt beep               # Disable "pc speaker" beep

bindkey -e

# Don't sort the completions for some commands
# which auto completion has been provided in a manual order
zstyle ':completion:*:aws-signon:*' sort false
zstyle ':completion:*:repoman:*' sort false
zstyle ':completion:*:repoman-test:*' sort false

# Autocomplete will complete past '-'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}'
zstyle ':completion:*' group-name ''

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:descriptions' format '[%d]'

################################################################################
# Initialize completion system
################################################################################

autoload -U compinit && compinit -i -d "${ZSH_COMPDUMP}"

# This has some arrays/maps that are used for auto-completion
source "${DOTFILES}/zsh/completions.helper.zsh"
source "${DOTFILES}/zsh/completions.zsh"

typeset fn_to_complete completion_fn
for fn_to_complete completion_fn in ${(kv)dotfiles_completion_functions}; do
    compdef "$completion_fn" "$fn_to_complete"
done
unset fn_to_complete completion_fn dotfiles_completion_functions

if [[ -d "${HOME}/.nvm" ]]; then
    # This loads nvm bash_completion
    [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"
fi

################################################################################
# Initialize plugins
################################################################################

if [[ -d "${DOTFILES}/deps/fzf-tab" ]]; then
    zstyle ':fzf-tab:*' group-name ''

    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no

    # switch group using `<` and `>`
    zstyle ':fzf-tab:*' switch-group '<' '>'

    source "${DOTFILES}/deps/fzf-tab/fzf-tab.plugin.zsh"
fi

if [[ -r "${DOTFILES}/deps/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    source "${DOTFILES}/deps/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

    bindkey '^ ' autosuggest-accept
fi

if [[ -r "${DOTFILES}/deps/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
    source "${DOTFILES}/deps/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi

################################################################################
# Initialize ender zsh theme
################################################################################

source "${DOTFILES}/zsh/ender.zsh-theme"

################################################################################
# Check for updates every 15 hours
################################################################################
dot-check-for-update --auto

# To run timer also uncomment lines at start of zshenv.zsh
if [[ -v ZSHENV_BOOT_TIMER ]]; then
    print -r -- "zshenv start time to zshrc end time: ${$(( (EPOCHREALTIME - ZSHENV_START_TIME) * 1000 ))%.*}ms"
    unset ZSHENV_BOOT_TIMER
fi
unset ZSHENV_START_TIME
