# These aliases are sourced in zshrc.zsh, so only available in interactive shells.

alias ls='ls --color=auto'
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
