#! /usr/bin/env zsh

set -euo pipefail

# Expect the following variables to be set:
# GIT_EMAIL
#   email to use for git commits
# DOTFILES_LOCAL_GIT_REPO
#   - git repo to clone for 'local' dotfiles.
#   - If not set, a local directory will be created
#   - if there's no reason to keep it seperate (like work specific configs that
#     should be stored in works cloud) then just use the `./local.${HOSTNAME}`
#     directory

do_brew=false
if [[ "$OSTYPE" == darwin* ]]; then
    do_brew=true
fi

autoload -Uz colors && colors

function print-header(){
    local color="$fg_bold[${1}]"
    local header="${(pl:80::=:)}"
    shift
    local message="${@}"
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}

function backup-file() {
    if [[ -f "${1}" ]]; then
        mv "${1}" "${1}.bak"
        echo "${1} backed up to ${1}.bak"
    fi
}

function safe-set-link() {
    local dest="${1}"
    local src="${2}"

    # safe-set-link is idempotent
    if [[ "${dest}" -ef "${src}" ]]; then
        return
    fi

    backup-file "${dest}"

    ln -s "${src}" "${dest}"
}

function safe-git-clone(){
    local url="${1}"
    local dest="${2}"

    # if the destination exists check to see if one of it's remotes is the given URL
    # if so skip cloning
    if [[ -d "${dest}" ]]; then
        pushd "${dest}" || {
            print-header red "❌ failed to validate existing git repo at ${dest}"
            return 1
        }
        local RESULT_COUNT
        RESULT_COUNT=$(git remote -v  | grep "${url}" | wc -l)
        popd || {
            print-header red "❌ failed to pop directory stack after checking existing git repo at ${dest}"
            return 1
        }

        if (( RESULT_COUNT >= 0 )); then
            return
        fi
    fi

    backup-file "${dest}"

    git clone --recursive "${url}" "${dest}"
}

if [[ $do_brew == true ]] && ! type brew &>/dev/null; then
    print-header green "Installing Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    print-header green "installing items from brew"
    brew install awscli docker docker-compose emacs fzf git the_silver_searcher zsh

    # These are mostly there for doomemacs but useful in general
    brew install shellcheck ripgrep pandoc
fi

DOTFILES="${HOME}/.dotfiles"

safe-git-clone "git@github.com:matt-sorenson/dotfiles.git" "${DOTFILES}"

print-header green "Setting up fzf-tab"
safe-git-clone "https://github.com/Aloxaf/fzf-tab" "${HOME}/.fzf-tab"

print-header green "Setting up zsh-syntax-highlighting"
safe-git-clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh-syntax-highlighting"

# Lets source zshenv so that we can use it's setup instead of duplicating it here
source "${DOTFILES}/zsh/zshenv.zsh"

if [[ "${OSTYPE}" =~ "darwin" ]]; then
    print-header blue "Setting up macOS specific files"

    print-header green "Setting up hammerspoon"
    safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"

    print-header blue "macOS specific files done"
fi

print-header green "Setting up zsh"
safe-set-link "${HOME}/.zshrc"    "${DOTFILES}/zsh/zshrc.zsh"
safe-set-link "${HOME}/.zshenv"   "${DOTFILES}/zsh/zshenv.zsh"

print-header green "Setting up misc dotfiles"
safe-set-link "${HOME}/.gitconfig" "${DOTFILES}/gitconfig"
safe-set-link "${HOME}/.tmux.conf" "${DOTFILES}/tmux.conf"

LOCAL_DOTFILES="${DOTFILES}/local.$(hostname -s)"

if [[ -d "${LOCAL_DOTFILES}" ]]; then
    print-header green "${LOCAL_DOTFILES} already exists, skipping creation"
else
    if [[ -z ${DOTFILES_LOCAL_GIT_REPO} ]]; then
        print-header green "DOTFILES_LOCAL_GIT_REPO not defined, creating default $LOCAL_DOTFILES"
        mkdir -p "${LOCAL_DOTFILES}"
        mkdir -p "${LOCAL_DOTFILES}/bin"
        mkdir -p "${LOCAL_DOTFILES}/zsh"
    else
        print-header green "checking out ${LOCAL_DOTFILES} from ${DOTFILES_LOCAL_GIT_REPO}"
        safe-git-clone "${DOTFILES_LOCAL_GIT_REPO}" "${LOCAL_DOTFILES}"
    fi
fi

safe-set-link "${DOTFILES}/local" "${LOCAL_DOTFILES}"

if ! mkdir -p "${DOTFILES}/tmp"; then
    print-header red "❌ Failed to create ${DOTFILES}/tmp directory"
fi

curr_dir="${PWD}"
if cd "${DOTFILES}" >> /dev/null; then
    git config --local user.email "${GIT_EMAIL:='matt@mattsorenson.com'}"
    cd "${curr_dir}" >> /dev/null || {
        print-header red "❌ Failed to pop directory stack after setting git email"
        exit 1
    }
else
    print-header red "❌ Failed to change directory to ${DOTFILES}"
    echo "this shouldn't happen, but if the folder does exist (which we just created it),"
    echo "then you can try running 'git config --local user.email \"\${GIT_EMAIL}\"' manually"
    echo "continuing anyways as this isn't a critical error"
fi

print-header green "Setting up doomemacs"

if ! command -v emacs >/dev/null 2>&1; then
    print-header yellow "emacs not found, consider installing it"
fi

mkdir -p "${HOME}/.config"
safe-git-clone "https://github.com/doomemacs/doomemacs" ~/.config/emacs
safe-set-link "${HOME}/.config/doom" "${DOTFILES}/doom"
exec "${HOME}/.config/emacs/bin/doom" install
