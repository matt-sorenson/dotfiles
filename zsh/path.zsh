add_to_path() {
    if [ ! -d "${1}" ] || [[ "${PATH}" =~ "(^|:)${1}(:|$)" ]]; then
        return 0
    fi

    PATH="${1}:${PATH}"
}

# osx /etc/zprofile borks the path so fix it...
if [ -x /usr/libexec/path_helper ]; then
    PATH=
    eval `/usr/libexec/path_helper -s`
fi

add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"
add_to_path "${DOTFILES}/bin"
add_to_path "${DOTFILES}/local/bin"
add_to_path "${HOME}/bin"

export PATH

if [ -d "${/usr/local/share/man}" ]; then
    export MANPATH="/usr/local/share/man:${MANPATH}"
fi
