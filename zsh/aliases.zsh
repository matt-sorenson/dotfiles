# These aliases are sourced in zshrc.zsh, so only available in interactive shells.

alias ls='ls --color=auto'
alias less='less -XF'
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

ws()     { pushd   "${WORKSPACE_ROOT_DIR}/${1}" }
wscode() { code    "${WORKSPACE_ROOT_DIR}/${1}" }
wsls() {
    local args=()
    local subdir=''

    while (( $# )); do
        case "$1" in
            -*|--*)
                args+=("$1")
                ;;
            *)
                if [[ -n "${subdir}" ]]; then
                    print-header -e "Subdirectory already set '${subdir}'."
                    return 1
                fi

                subdir="$1"
                ;;
        esac
        shift
    done

    ls "${args[@]}" "${WORKSPACE_ROOT_DIR}/${subdir}"
}

# pbpaste is osx specific, try a few fallback options if available.
if ! command -v pbpaste > /dev/null; then
    if command -v xsel > /dev/null; then
        alias pbpaste='xsel --clipboard --output'
    elif command -v xclip > /dev/null; then
        alias pbcopy='xclip -selection clipboard'
    fi
fi

auto-dot-check-for-update() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt typeset_to_unset

    local date_cmd=()
    if command -v gdate > /dev/null; then
        date_cmd=(gdate -d)
    elif date --version >/dev/null 2>&1; then
        date_cmd=(date -d)
    else
        date_cmd=(date -j -f "%Y-%m-%dT%H:%M:%SZ")
    fi

    local hours="${1:-15}"
    local time_limit_in_seconds=$(( 60 * 60 * hours ))
    local current_time=$(date +%s)
    local cutoff_time=$(( current_time - time_limit_in_seconds ))

    local -i last_update
    local update_filename="${DOTFILES}/tmp/dotfile-update"
    if [[ -r "${update_filename}" ]]; then
        if ! last_update="$( "${date_cmd[@]}" "$(<"$update_filename")" "+%s" )"; then
            last_update=0
        fi
    else
        last_update=0
    fi

    if (( last_update < cutoff_time )); then
        read -q "RUN_UPDATE?It's been a while, update dotfiles? "
        print ''
        if [[ "${RUN_UPDATE:l}" == "y" ]]; then
            dot-check-for-update
        fi
    fi
}

autoload \
    aws-signon \
    brew-find-leafs \
    clang-format-ri \
    dot-check-for-update \
    dot-check-for-update-git \
    git-alias \
    git-dag \
    git-popb \
    git-pushb \
    git-stack \
    jwt-print \
    repoman
