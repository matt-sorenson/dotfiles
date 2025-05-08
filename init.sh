#! /usr/bin/env zsh

# Expect the following variables to be set:
# GIT_EMAIL
#   email to use for git commits
# DOTFILES_LOCAL_GIT_REPO
#   - git repo to clone for 'local' dotfiles.
#   - If not set, a local directory will be created
#   - if there's no reason to keep it seperate (like work specific configs that
#     should be stored in works cloud) then just use the `./local.${HOSTNAME}`
#     directory

autoload -Uz colors && colors

backup-file() {
    if [ -f "${1}" ]; then
        mv "${1}" "${1}.bak"
        echo "${1} backed up to ${1}.bak"
    fi
}

safe-set-link() {
    local dest="${1}"
    local src="${2}"

    # safe-set-link is idempotent
    if [ "${dest}" -ef "${src}" ]; then
        return
    fi

    backup-file "${dest}"

    ln -s "${src}" "${dest}"
}

safe-git-clone(){
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

    backup-file "${dest}"

    git clone --recursive "${url}" "${dest}"
}

print-header(){
    local color="$fg_bold[${1}]"
    local header="================================================================================"
    shift
    local message="${@}"
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}

DOTFILES="${HOME}/.dotfiles"

safe-git-clone "git@github.com:matt-sorenson/dotfiles.git" "${DOTFILES}"

print-header green "Setting up fzf-tab"
safe-git-clone "https://github.com/Aloxaf/fzf-tab" "${HOME}/.fzf-tab"

print-header green "Setting up zsh-syntax-highlighting"
safe-git-clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh-syntax-highlighting"

if [[ "${OSTYPE}" =~ "darwin" ]]; then
    print-header blue "Setting up macOS specific files"

    print-header green "Setting up hammerspoon"
    safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"
    safe-set-link "${HOME}/.hammerspoon/local" "${DOTFILES}/local"

    print-header blue "macOS specific files done"
fi

print-header green "Setting up zsh"
safe-set-link "${HOME}/.zshrc"    "${DOTFILES}/zsh/zshrc.zsh"
safe-set-link "${HOME}/.zshenv"   "${DOTFILES}/zsh/zshenv.zsh"

print-header green "Setting up misc dotfiles"
safe-set-link "${HOME}/.gitconfig" "${DOTFILES}/gitconfig"
safe-set-link "${HOME}/.tmux.conf" "${DOTFILES}/tmux.conf"

local LOCAL_DOTFILES="${DOTFILES}/local.$(hostname -s)"

if [ -d "${LOCAL_DOTFILES}" ]; then
    print-header green "${LOCAL_DOTFILES} already exists, skipping creation"
else
    if [ -z ${DOTFILES_LOCAL_GIT_REPO} ]; then
        print-header green "DOTFILES_LOCAL_GIT_REPO not defined, creating default $LOCAL_DOTFILES"
        mkdir -p "${LOCAL_DOTFILES}"
    else
        print-header green "checking out ${LOCAL_DOTFILES} from ${DOTFILES_LOCAL_GIT_REPO}"
        safe-git-clone "${DOTFILES_LOCAL_GIT_REPO}" "${LOCAL_DOTFILES}"
    fi
fi

safe-set-link "${DOTFILES}/local" "${LOCAL_DOTFILES}"

mkdir -p "${DOTFILES}/tmp"

pushd "${DOTFILES}"
git config --local user.email "${GIT_EMAIL:='matt@mattsorenson.com'}"
popd

print-header green "Setting up doomemacs"
safe-git-clone "https://github.com/doomemacs/doomemacs" ~/.config/emacs
~/.config/emacs/bin/doom install
