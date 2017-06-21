add_to_path() {
    if [ -d "${1}" ] && [[ ! "${PATH}" =~ "(^|:)${1}(:|$)" ]]; then
        PATH="${1}:${PATH}"
    fi
}

add_to_end_of_path() {
    if [ -d "${1}" ] && [[ ! "${PATH}" =~ "(^|:)${1}(:|$)" ]]; then
        PATH="${PATH}:${1}"
    fi
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
