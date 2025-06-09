# These aliases are sourced in zshrc.zsh, so only available in interactive shells.

alias less='less -XF'
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

wsls()   { ls "$@" "${WORKSPACE_ROOT_DIR}" }
ws()     { pushd   "${WORKSPACE_ROOT_DIR}/${1}" }
wscode() { code    "${WORKSPACE_ROOT_DIR}/${1}" }

auto-dot-check-for-update() {
    local hours="${1:-15}"
    local time_limit_in_seconds=$(( 60 * 60 * hours ))
    local current_time=$(date +%s)
    local cuttoff_time=$(($current_time - $time_limit_in_seconds))

    # If the file doesn't exist we treat it as if it was last updated at the epoch
    local last_update=0
    local update_filename="${DOTFILES}/tmp/dotfile-update"
    if [[ -f "${update_filename}" ]]; then
        last_update=$(cat "${update_filename}")
    fi

    if (( last_update < cuttoff_time )); then
        read -q "RUN_UPDATE?It's been a while, update dotfiles? "
        echo '' # read -q doesn't output a newline
        if [[ "${RUN_UPDATE:l}" == "y" ]]; then
            dot-check-for-update;
        fi
    fi
}

add-to-fpath "${DOTFILES}/bin"
add-to-fpath "${DOTFILES}/local/bin"

autoload clang-format-ri jwt-print git-popb git-pushb git-stack
