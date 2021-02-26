add-to-path() {
    if [ -d "${1}" ] && [[ ! "${PATH}" =~ "(^|:)${1}(:|$)" ]]; then
        PATH="${1}:${PATH}"
    fi
}

# osx /etc/zprofile borks the path so fix it...
if [ -x /usr/libexec/path_helper ]; then
    PATH=
    eval `/usr/libexec/path_helper -s`
fi

add-to-path "/usr/local/bin"
add-to-path "/usr/local/sbin"
add-to-path "${DOTFILES}/bin"
add-to-path "${DOTFILES}/local/bin"
add-to-path "${HOME}/bin"
add-to-path "${HOME}/.rbenv/bin"
add-to-path "${HOME}/.yarn/bin"
add-to-path "${HOME}/.config/yarn/global/node_modules/.bin"
add-to-path "/usr/local/Cellar/postgresql@9.5/9.5.25/bin"

export PATH

if [ -d "/usr/local/share/man" ]; then
    export MANPATH="/usr/local/share/man:${MANPATH}"
fi
