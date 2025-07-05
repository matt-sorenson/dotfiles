#! /usr/bin/env zsh

emulate -L zsh
set -euo pipefail
setopt typeset_to_unset

print-header "Starting create-zsh-script.zsh"

local name
local base_dir

while (( $# )); do
    case "$1" in
        -h|--help)
            ;;
        -t|--type)
            if (( $# < 2 )); then
                print-header -e "--type requires an argument"
                return 1
            fi

            shift
            if [[ "$1" == 'function' || "$1" == 'func' ]]; then
                base_dir=bin-func
            elif [[ "$1" == 'bin' ]]; then
                base_dir=bin
            else
                print-header -e "Unknown type: $1"
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
target="${DOTFILES}/${base_dir}/${name}"

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

code ${(q)target}

print-header green "✅ Created: $target"
