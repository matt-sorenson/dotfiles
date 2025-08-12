#! /usr/bin/env zsh

emulate -L zsh
set -euo pipefail
setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
unsetopt short_loops

print-header "Starting create-zsh-script.zsh"

local _usage="Usage: create-zsh-script.zsh [-t|--type <type>] [-l|--location <loc>] [-h|--help] <name>

Options:
  -h, --help            Show this help message
  -t, --type <type>     Specify the type of script [function, func, or bin] (default: bin)
  -l, --location <loc>  Specify the location [dotfiles or local] (default: dotfiles)"

local name
local base_dir="${DOTFILES}"
local bin_dir="bin"

while (( $# )); do
    case "$1" in
        -h|--help)
            print "$_usage"
            return 0
            ;;
        -t|--type)
            if (( $# < 2 )); then
                print-header -e "--type requires an argument"
                return 1
            fi

            shift
            if [[ "$1" == 'function' || "$1" == 'func' ]]; then
                bin_dir=bin-func
            elif [[ "$1" == 'bin' ]]; then
                bin_dir=bin
            else
                print-header -e "Unknown type: $1"
                return 1
            fi
            ;;
        -l|--location)
            if (( $# < 2 )); then
                print-header -e "--location requires an argument"
                return 1
            fi

            shift
            if [[ "$1" == 'dotfiles' ]]; then
                base_dir="${DOTFILES}"
            elif [[ "$1" == 'local' ]]; then
                base_dir="${DOTFILES}/local"
            else
                print-header -e "Unknown location: $1"
                return 1
            fi
            ;;
        *)
            if [[ -v name ]]; then
                print-header -e "Too many parameters. Only one script can be created at a time"
                return 1
            fi

            name="$1"
            ;;
    esac

    shift
done

if [[ ! -v name ]]; then
    print-header -e "Script name not provided." >&2
    return 1
fi

template="${DOTFILES}/templates/bin/new_script.zsh"
target="${base_dir}/${bin_dir}/${name}"

mkdir -p "${base_dir}/${bin_dir}"

if [[ ! -r "${template}" ]]; then
    print-header -e "Template '${template}' not found." >&2
    return 1
fi

if [[ -e "${target}" ]]; then
    print-header -e "File '${target}' already exists." >&2
    return 1
fi

mkdir -p "${base_dir}"

# Replace <name> with the input value
sed "s/<name>/${name}/g" "${template}" > "${target}"
chmod 755 "${target}"

vseditor ${(q)target}

print-header green "✅ Created: $target"
