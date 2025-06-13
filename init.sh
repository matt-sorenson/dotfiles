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

function() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

    autoload -Uz colors && colors

    function print-header(){
        local color="$fg_bold[${1}]"
        shift
        local header="${(pl:80::=:)}"
        print "$color${header}\n= ${$@}\n${header}$reset_color"
    }

    function safe-set-link() {
        local dest="${1}"
        local src="${2}"

        # If the destination is already linked to the source do nothing
        if [[ "${dest}" -ef "${src}" ]]; then
            return 0
        elif [[ -f "${dest}" ]]; then
            mv "${dest}" "${dest}.bak"
            print "${dest} backed up to ${dest}.bak"
        fi

        ln -s "${src}" "${dest}"
    }

    function safe-git-clone(){
        local url="${1}"
        local dest="${2}"

        # if the destination exists check to see if one of it's remotes is the given URL
        # if so skip cloning
        if [[ -d "${dest}" ]]; then
            if git -C "$dir" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                local result_count=$(git remote -v -C ${dest} | grep "${url}" | wc -l)

                # If result_count is greater than 0 that means the remote repo
                # already exists in the destination directory.
                if (( result_count > 0 )); then
                    print green "✅ Destination directory ${dest} already exists with remote ${url}"
                    return 0
                fi
            fi

            if [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
                print-header red "❌ safe-git-clone: Destination directory ${dest} already exists and is not empty"
                return 1
            fi
        fi

        git clone --recursive "${url}" "${dest}"
    }

    local do_brew=false
    if [[ "$OSTYPE" == darwin* ]]; then
        do_brew=true
    fi

    local DOTFILES="${HOME}/.dotfiles"
    local LOCAL_DOTFILES="${DOTFILES}/local.$(hostname -s)"

    if [[ -d "${DOTFILES}/local" ]]; then
        LOCAL_DOTFILES="${DOTFILES}/local"
    fi

    if [[ $do_brew == true ]] && ! command -v brew &> /dev/null; then
        print-header green "Installing Homebrew"

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        local brew_install_list=(
            awscli
            docker
            docker-compose
            emacs
            fzf
            git
            the_silver_searcher
            zsh

            # These are mostly there for doomemacs but useful in general
            shellcheck
            ripgrep
            pandoc
        )

        print-header green "installing items from brew"
        brew install "${brew_install_list[@]}"
    fi

    safe-git-clone "git@github.com:matt-sorenson/dotfiles.git" "${DOTFILES}"

    mkdir "${DOTFILES}/deps"

    print-header green "Setting up fzf-tab"
    safe-git-clone "https://github.com/Aloxaf/fzf-tab" "${DOTFILES}/deps/fzf-tab"

    print-header green "Setting up zsh-syntax-highlighting"
    safe-git-clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${DOTFILES}/deps/zsh-syntax-highlighting"

    # Lets source zshenv so that we can use it's setup instead of duplicating it here
    unset -f print-header
    source "${DOTFILES}/zsh/zshenv.zsh"

    print-header green "Setting up zsh"
    safe-set-link "${HOME}/.zshrc"    "${DOTFILES}/zsh/zshrc.zsh"
    safe-set-link "${HOME}/.zshenv"   "${DOTFILES}/zsh/zshenv.zsh"

    print-header green "Setting up misc dotfiles"
    safe-set-link "${HOME}/.gitconfig" "${DOTFILES}/gitconfig"

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
        print-header -e "Failed to create ${DOTFILES}/tmp directory"
    fi

    if ! git -C "${DOTFILES}" config --local user.email "${GIT_EMAIL:='matt@mattsorenson.com'}"; then
        print-header -w "Failed to set git user.email in ${DOTFILES}"
        print "You can change to the directory directly and try \'git config --local user.email \"you@example.com\"\'"
    fi

    if [[ "${OSTYPE}" =~ "darwin" ]]; then
        print-header blue "Setting up macOS specific files"

        print-header green "Setting up hammerspoon"
        safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"

        print-header blue "macOS specific files done"
    fi

    if command -v emacs > /dev/null 2>&1; then
        print-header green "Setting up doomemacs"
        mkdir -p "${HOME}/.config"
        safe-git-clone "https://github.com/doomemacs/doomemacs" ~/.config/emacs
        safe-set-link "${HOME}/.config/doom" "${DOTFILES}/doom"
        eval "${HOME}/.config/emacs/bin/doom install"
    else
        print-header -w "emacs not found, consider installing it"
        print "Skipping doomemacs setup"
    fi

    print-header green "Setting up local dotfiles complete."
    print "You should restart your terminal now to apply the changes."
} "$@"
