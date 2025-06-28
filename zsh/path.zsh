add-to-path() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

    local show_help=0
    local do_fpath=0
    local parse_error=0
    local operation="prepend"
    local dir=""

    local cmd="add-to-path"
    local fpath_opt_str="[-f|--fpath] "
    local fpath_des_str="
        -f, --fpath         Add to fpath instead of path"

    while (( $# )); do
        case "$1" in
            -h|--help)
                show_help=1
                ;;
            -f|--fpath)
                do_fpath=1
                ;;
            --add-to-fpath)
                # This is a 'secret' option specifically for add-to-fpath
                # to allow -h/--help to show the add-to-fpath option
                do_fpath=1
                cmd="add-to-fpath"
                fpath_opt_str=''
                fpath_des_str=''
                ;;
            -o|--operation)
                shift
                case "$1" in
                    prepend|append)
                        operation="$1"
                        ;;
                    *)
                        if [[ -z "$1" ]]; then
                            print "Error: No operation specified for --operation."
                        else
                            print "Unknown operation: '%1'. Valid operations are 'prepend' or 'append'.\n"
                        fi
                        parse_error=1
                        ;;
                esac
                ;;
            *)
                if [[ -z "${dir}" ]]; then
                    dir="$1"
                else
                    print "Unexpected argument: '%1'\n"
                    parse_error=1
                fi
                ;;
        esac
        shift
    done

    local usage="Usage: $cmd [-o|--operation prepend|append] ${fpath_opt_str}<directory>

    Options:
        -h, --help          Show this help message${fpath_des_str}
        -o, --operation     Specify operation: 'prepend' or 'append' (default: 'prepend')"
    # Make sure an argument was provided
    if (( show_help )); then
        print "${usage}"
        return 0
    elif (( parse_error )); then
        print "${usage}"
        return 1
    elif [[ -z "${dir}" ]]; then
        print "Error: No directory specified.\n${usage}"
        return 1
    fi

    # Check that it exists and is a directory
    if [[ ! -d "${dir}" ]]; then
        return 1
    fi

    # Resolve to an absolute path
    dir="${dir:A}"

    if (( do_fpath )); then
        # Check that it's not in the fpath already
        if [[ ":$FPATH:" != *":${dir}:"* ]]; then
            # Prepend it to path
            if [[ "${operation}" == "prepend" ]]; then
                fpath=("${dir}" "${fpath[@]}")
            else
                fpath+=("${dir}")
            fi
        fi
    else
        # Check that it's not in the path already
        if [[ ":$PATH:" != *":${dir}:"* ]]; then
            # Prepend it to path
            if [[ "${operation}" == "prepend" ]]; then
                path=("${dir}" "${path[@]}")
            else
                path+=("${dir}")
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
    eval "$(/usr/libexec/path_helper -s)"
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
elif [[ -d "${HOME}/.pnpm" ]]; then
    export PNPM_HOME="${HOME}/.pnpm"
fi

if [[ -v PNPM_HOME ]]; then
    add-to-path "${PNPM_HOME}"
fi

add-to-path '/opt/homebrew/bin'
add-to-path '/opt/homebrew/sbin'

add-to-fpath "${DOTFILES}/bin"
add-to-fpath "${DOTFILES}/local/bin"
