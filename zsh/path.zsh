add-to-path() {
    local dir="$1"

    # Make sure an argument was provided
    if [[ -z "$dir" ]]; then
        echo "Usage: add-to-path <directory>"
        return 1
    fi

    # Resolve to an absolute path
    dir="${dir:A}"

    # Check that it exists and is a directory
    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    # Check if it’s already in path
    for existing in "${path[@]}"; do
        if [[ "$existing" == "$dir" ]]; then
            # Already present; nothing to do
            return 0
        fi
    done

    # Prepend it to path
    path=("$dir" "${path[@]}")
    return 0
}

function add-to-fpath() {
    local dir="$1"

    # Make sure an argument was provided
    if [[ -z "$dir" ]]; then
        echo "Usage: add-to-fpath <directory>"
        return 1
    fi

    # Resolve to an absolute path
    dir="${dir:A}"

    # Check that it exists and is a directory
    if [[ ! -d "$dir" ]]; then
        echo "Error: '$dir' is not a directory."
        return 1
    fi

    # Check if it’s already in fpath
    for existing in "${fpath[@]}"; do
        if [[ "$existing" == "$dir" ]]; then
            # Already present; nothing to do
            return 0
        fi
    done

    # Prepend it to fpath
    fpath=("$dir" "${fpath[@]}")
    return 0
}

# osx /etc/zprofile borks the path so fix it...
if [ -x /usr/libexec/path_helper ]; then
    path=()
    eval `/usr/libexec/path_helper -s`
fi

add-to-path "/usr/local/bin"
add-to-path "/usr/local/sbin"
add-to-path "${DOTFILES}/bin"
add-to-path "${DOTFILES}/local/bin"
add-to-path "${HOME}/bin"
add-to-path "${HOME}/.rbenv/bin"
add-to-path "${HOME}/.config/emacs/bin"

if [ -d "${HOME}/Library/pnpm" ]; then
  export PNPM_HOME="${HOME}/Library/pnpm"
fi
add-to-path "${HOME}/Library/pnpm"

add-to-path '/opt/homebrew/bin'
add-to-path '/opt/homebrew/sbin'

if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d "/usr/local/share/man" ]; then
    export MANPATH="/usr/local/share/man:${MANPATH}"
fi
