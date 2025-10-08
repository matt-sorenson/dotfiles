# Lazy load nvm to speed up shell startup time, though the first call to
# npm/node/nvm/pnpm/npx will be slower.
if [[ -d "${HOME}/.nvm" ]]; then
    export NVM_DIR="${HOME}/.nvm"
elif [[ -d "/usr/local/opt/nvm" ]]; then
    export NVM_DIR="/usr/local/opt/nvm"
elif command -v brew; then
    if brew list --versions nvm &> /dev/null; then
        NVM_DIR="$(brew --prefix nvm)"
    fi
fi

if [[ -v NVM_DIR ]]; then
    if [[ ! -d "${NVM_DIR}" ]]; then
        print-header -e "NVM_DIR is set but '${NVM_DIR}' does not exist"
        return 1
    else
        local -a _dot_nvm_lazy_cmds=(corepack node npm npx nvm pnpm pnpx yarn prettier)

        _dot_nvm_lazy_load() {
            emulate -L zsh
            set -uo pipefail
            setopt err_return extended_glob typeset_to_unset warn_create_global
            unsetopt short_loops

            local install_msg
            if command -v brew &> /dev/null; then
                install_msg="try \`brew install nvm\` and restarting your shell."
            fi

            local error=0
            if [[ ! -f "${NVM_DIR}/nvm.sh" ]]; then
                print-header -e "_dot_nvm_lazy_load failed because '${NVM_DIR}/nvm.sh' is missing"
                error=1
            elif [[ ! -r "${NVM_DIR}/nvm.sh" ]]; then
                print-header -e "_dot_nvm_lazy_load failed because '${NVM_DIR}/nvm.sh' is not readable"
                error=1
            elif [[ ! -s "${NVM_DIR}/nvm.sh" ]]; then
                print-header -e "_dot_nvm_lazy_load failed because '${NVM_DIR}/nvm.sh' is empty"
                error=1
            fi

            if (( error )); then
                if [[ -v install_msg ]]; then
                    print "${install_msg}"
                fi

                return 1
            fi

            local cmd
            for cmd in "${_dot_nvm_lazy_cmds[@]}"; do
                unset -f "$cmd"
            done
            unset -f _dot_nvm_lazy_load

            unsetopt warn_create_global
            source "${NVM_DIR}/nvm.sh"
            setopt warn_create_global

            if (( $# )); then
                local cmd="$1"
                shift

                $cmd "$@"
            fi
        }

        for cmd in "${_dot_nvm_lazy_cmds[@]}"; do
            eval "function $cmd() { _dot_nvm_lazy_load $cmd \"\$@\" }"
        done
    fi
fi
