#! /usr/bin/env zsh

autoload -Uz colors && colors

backup_file() {
    if [ -f "${1}" ]; then
        mv "${1}" "${1}.bak"
        echo "${1} backed up to ${1}.bak"
    fi
}

safe_set_link() {
    local dest="${1}"
    local src="${2}"

    # safe_set_link is idempotent
    if [ "${dest}" -ef "${src}" ]; then
        return
    fi

    backup_file "${dest}"

    ln -s "${src}" "${dest}"
}

safe_git_clone(){
    local url="${1}"
    local dest="${2}"

    # if the destination exists check to see if one of it's remotes is the given URL
    # if so skip cloning
    if [ -d "${dest}" ]; then
        pushd "${dest}"
        local RESULT_COUNT=`git remote -v  | grep "${url}" | wc -l`
        popd

        if [ $((RESULT_COUNT)) -ge 0 ]; then
            return
        fi
    fi

    backup_file "${dest}"

    git clone --recursive "${url}" "${dest}"
}

print_header(){
    local color="$fg_bold[${1}]"
    local header="================================================================================"
    local message="${@}"
    shift
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}

DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"

#safe_git_clone "git@bitbucket.org:ender341/dotfiles.git" "${DOTFILES}"

print_header green "Setting up spacemacs"
safe_git_clone "https://github.com/syl20bnr/spacemacs" "${HOME}/.emacs.d"
safe_set_link "${HOME}/.spacemacs" "${DOTFILES}/spacemacs.el"

print_header green "Setting up prezto"
safe_git_clone "https://github.com/zsh-users/prezto.git" "${HOME}/.zprezto"
safe_set_link "${HOME}/.zprezto/modules/prompt/functions/prompt_ender_setup" "${DOTFILES}/zsh/ender.zsh-theme"
safe_set_link "${HOME}/.zpreztorc" "${DOTFILES}/zpreztorc.zsh"

if [[ "${OSTYPE}" =~ "darwin" ]]; then
    print_header blue "Setting up macOS specific files"

    print_header green "Setting up hammerspoon"
    safe_set_link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"

    print_header green "Settings up karabiner"
    mkdir -p "${HOME}/.config/karabiner/"
    safe_set_link "${HOME}/.config/karabiner/karabiner.json" "${DOTFILES}/karabiner.json"

    print_header blue "macOS specific files done"
fi

print_header green "Setting up zsh"
safe_set_link "${HOME}/.zshrc"    "${DOTFILES}/zsh/zshrc.zsh"
safe_set_link "${HOME}/.zshenv"   "${DOTFILES}/zsh/zshenv.zsh"

print_header green "Setting up misc dotfiles"
safe_set_link "${HOME}/.gitconfig" "${DOTFILES}/gitconfig"
safe_set_link "${HOME}/.tmux.conf" "${DOTFILES}/tmux.conf"

local LOCAL_DOTFILES="${DOTFILES}/local.$(hostname -s)"

if [ -d "${LOCAL_DOTFILES}" ]; then
    print_header green "${LOCAL_DOTFILES} already exists, skipping creation"
else
    if [ -z ${DOTFILES_LOCAL_GIT_REPO} ]; then
        print_header green "DOTFILES_LOCAL_GIT_REPO not defined, creating default $LOCAL_DOTFILES"
        mkdir -p "${LOCAL_DOTFILES}"
    else
        print_header green "checking out ${LOCAL_DOTFILES} from ${DOTFILES_LOCAL_GIT_REPO}"
        safe_git_clone "${DOTFILES_LOCAL_GIT_REPO}" "${LOCAL_DOTFILES}"
    fi
fi

safe_set_link "${DOTFILES}/local" "${LOCAL_DOTFILES}"

mkdir -p "${DOTFILES}/tmp"
