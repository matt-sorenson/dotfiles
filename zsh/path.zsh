add-to-path() {
    local show_help=0
    local do_fpath=0
    local parse_error=0
    local operation="prepend"
    local dir=""

    local cmd="$0"
    local fpath_str="[-f|--fpath] "

    while (( $# )); do
        case "$1" in
            -h|--help)
                show_help=1
                ;;
            -f|--fpath)
                do_fpath=1
                ;;
            --add-to-fpath)
                do_fpath=1
                cmd="add-to-fpath"
                fpath_str=''
                ;;
            -o|--operation)
                shift
                case "$1" in
                    prepend|append)
                        operation="$1"
                        ;;
                    *)
                        printf "%s\n" "Unknown operation: '$1'. Valid operations are 'prepend' or 'append'."
                        parse_error=1
                        ;;
                esac
                ;;
            *)
                if [[ -z "$dir" ]]; then
                    dir="$1"
                else
                    printf "%s\n" "Unexpected argument: '$1'."
                    parse_error=1
                fi
                ;;
        esac
        shift
    done

    local usage="Usage: $cmd [-o|--operation prepend|append] ${fpath_str}<directory>

    Options:
        -h, --help          Show this help message
        -f, --fpath         Add to fpath instead of path (defaults: false)
        -o, --operation     Specify operation: 'prepend' or 'append' (default: 'prepend')
"
    # Make sure an argument was provided
    if (( show_help )); then
        printf "%s" "$usage"
        return 0
    elif (( parse_error )); then
        printf "%s" "$usage"
        return 1
    elif [[ -z "$dir" ]]; then
        printf "%s\n%s" "Error: No directory specified." "$usage"
        return 1
    fi

    # Resolve to an absolute path
    dir="${dir:A}"

    # Check that it exists and is a directory
    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    if (( do_fpath )); then
        # Check that it's not in the fpath already
        if [[ ":$FPATH:" != *":$dir:"* ]]; then
            # Prepend it to path
            if [[ "$operation" == "prepend" ]]; then
                fpath=("$dir" "${fpath[@]}")
            else
                fpath+=("$dir")
            fi
        fi
    else
        # Check that it's not in the path already
        if [[ ":$PATH:" != *":$dir:"* ]]; then
            # Prepend it to path
            if [[ "$operation" == "prepend" ]]; then
                path=("$dir" "${path[@]}")
            else
                path+=("$dir")
            fi
        fi
    fi

    return 0
}

add-to-fpath() {
    add-to-path -f --add-to-fpath "$@"
}

# osx /etc/zprofile borks the path so fix it...
if [[ -x /usr/libexec/path_helper ]]; then
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

if [[ -d "${HOME}/Library/pnpm" ]]; then
  export PNPM_HOME="${HOME}/Library/pnpm"
fi
add-to-path "${HOME}/Library/pnpm"

add-to-path '/opt/homebrew/bin'
add-to-path '/opt/homebrew/sbin'
