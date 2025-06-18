#! /usr/bin/env zsh

# Expect the following variables to be set:

if ! command -v print-header &> /dev/null; then
    autoload -Uz colors && colors

    function print-header(){
        emulate -L zsh
        set -uo pipefail
        setopt err_return

        local color=''
        local prefix=''
        if [[ $1 == '-e' ]]; then
            color="${fg_bold[red]}"
            prefix='❌ '
        elif [[ $1 == '-w' ]]; then
            color="${fg_bold[yellow]}"
            prefix='⚠️ '
        else
            color="${fg_bold[${1}]}"
        fi
        shift

        local header="${(l:80::=:):-}"
        print "${color}${header}\n= ${prefix}$*\n${header}$reset_color"
    }
fi

function main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

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
        local url dest
        local extra_args=()

        while (( $# )); do
            case "$1" in
                -s|--shallow)
                    extra_args+=(--depth 1)
                    ;;
                -*)
                    print-header -e "Unknown option: $1"
                    return 1
                    ;;
                *)
                    if [[ -z "${url}" ]]; then
                        url="$1"
                    elif [[ -z "${dest}" ]]; then
                        dest="$1"
                    else
                        print-header -e "Too many arguments: $1"
                        return 1
                    fi
                    ;;
            esac
            shift
        done


        # if the destination exists check to see if one of it's remotes is the given URL
        # if so skip cloning
        if [[ -d "${dest}" ]]; then
            if git -C "${dest}" rev-parse --is-inside-work-tree &> /dev/null; then
                local urls=("$url")
                # If it's a github repo check for either the https or ssh URL
                # Otherwise just use the URL as is.
                if [[ "${url}" =~ '^git@github.com:(.+)$' ]]; then
                    urls+=("https://github.com/${match[1]}")
                elif [[ "${url}" =~ '^https://github.com/(.+)$' ]]; then
                    urls+=("git@github.com:${match[1]}")
                fi

                local remote
                for remote in "${urls[@]}"; do
                    if git -C "${dest}" remote -v | grep -q -- "${remote}"; then
                        print-header green "✅ Destination directory ${dest} already exists with remote ${remote}"
                        return 0
                    fi
                done
                unset remote
            fi

            if [[ -n "$(ls -A "${dest}" 2> /dev/null)" ]]; then
                print-header -e "safe-git-clone: Destination directory ${dest} already exists and is not empty"
                return 1
            fi
        fi

        git clone "${extra_args[@]}" "${url}" "${dest}"
    }

    local app_install_list=(
        fzf
        git
        zsh

        # These are mostly there for doomemacs but useful in general
        pandoc
        ripgrep
        shellcheck
    )

    local -a apt_install_list=(
        emacs-nox # emacs-nox is the terminal version of emacs
        silversearcher-ag
    )

    local -a brew_install_list=(
        awscli
        emacs
        the_silver_searcher
    )

    local do_debian_apt=0
    local debian_specific_help=''
    if command -v apt &> /dev/null; then
        do_debian_apt=1
        debian_specific_help="
  --no-debian-apt    Do not install packages using apt"
    fi

    local do_brew=0
    local do_hammerspoon=0
    local mac_specific_help=''
    if [[ "${OSTYPE}" == darwin* ]]; then
        do_brew=1
        do_hammerspoon=1
        mac_specific_help="
  --no-brew          Do not install Homebrew
  --no-hammerspoon   Do not set up Hammerspoon"
    fi

    local do_docker=1
    local do_doomemacs=1

    local -A plugins=(
        [fzf-tab]="shallow=https://github.com/Aloxaf/fzf-tab"
        [zsh-syntax-highlighting]="shallow=https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    export DOTFILES="${DOTFILES:-${HOME}/.dotfiles}"

    local git_email=''
    local is_work=0
    local local_set=0
    local LOCAL_DOTFILES="${DOTFILES}/local"

    while (( $# )); do
        case "$1" in
            --no-brew)
                do_brew=0
                ;;
            --no-debian-apt)
                do_debian_apt=0
                ;;
            --no-hammerspoon)
                do_hammerspoon=0
                ;;
            --no-fzf)
                unset "plugins[fzf-tab]"
                ;;
            --no-syntax)
                unset "plugins[zsh-syntax-highlighting]"
                ;;
            --no-docker)
                do_docker=0
                ;;
            --no-doomemacs) ;& # fallthrough
            --no-doom)
                do_doomemacs=0
                ;;
            --plugin|-p)
                shift
                local plugin_name plugin_url

                if (( $# == 0 )); then
                    print-header -e "--plugin requires a value in the format name=url"
                    return 1
                elif [[ "$1" == *=* ]]; then
                    # Format: name=url
                    plugin_name="${1%%=*}"
                    plugin_url="${1#*=}"

                    if [[ -z "${plugin_name}" || -z "${plugin_url}" ]]; then
                        print-header -e "--plugin argument must include both name and URL"
                        return 1
                    fi
                elif [[ "$1" =~ '^(https://github\.com|github\.com:)([^/]+)/([^/?#]+?)(\.git)?/?$' ]]; then
                    plugin_name="${match[3]%.git}"
                    plugin_url="$1"
                else
                    print-header -e "--plugin must be in the format name=url or a valid GitHub URL"
                    return 1
                fi

                plugins["${plugin_name}"]="${plugin_url}"

                if [[ ${plugin_name} == 'local' ]]; then
                    if (( local_set )); then
                        print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                        return 1
                    fi

                    local_set=1
                    LOCAL_DOTFILES="${DOTFILES}/deps/local"
                fi
                ;;
            --local-ref)
                shift
                if (( $# == 0 )); then
                    print-header -e "--local-ref requires a value"
                    return 1
                elif (( local_set )); then
                    print-header -e "--local-ref set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                    return 1
                fi
                local_set=1
                LOCAL_DOTFILES="${DOTFILES}/$1"
                ;;
            --work|-w)
                is_work=1
                ;;
            --help|-h)
                print "Usage: init.sh [OPTIONS]
Options:${mac_specific_help}${debian_specific_help}
  --work, -w                    Set up local/is_work file so hammerspoon & scripts can detect work environment
  --local-git <url>             Use the specified git repo for local dotfiles
  --local-ref <ref>             Use the specified reference for local dotfiles
  --no-fzf                      Do not install fzf-tab plugin
  --no-syntax                   Do not install zsh-syntax-highlighting plugin
  --no-docker                   Do not install Docker
  --no-doom, --no-doomemacs     Do not install Doom Emacs
  --plugin <name=[shallow=]url> Add a custom plugin to install
                                Plugins added here will be automatically updated with the dot-check-for-update script
                                You'll need to manually source/init zsh plugins (that aren't 'local' or in the default list).
                                Shallow flags the repo to be cloned with --depth 1, which is useful for large repos.

  --help, -h                    Show this help message"
                return 0
                ;;
            --git-email)
                shift
                if (( $# == 0 )); then
                    print-header -e "--git-email requires a value"
                    return 1
                fi
                git_email="$1"
                ;;
            --git-email-matt)
                git_email="matt@mattsorenson.com"
                ;;
            *)
                print-header -e "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done

    if command -v locale-gen &> /dev/null; then
        sudo locale-gen en_US en_US.UTF-8
    fi

    if (( do_brew )); then
        if ! command -v brew &> /dev/null; then
            print-header green "Installing Homebrew"

            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        if (( do_docker )); then
            brew_install_list+=( docker docker-compose )
        fi

        print-header green "installing items from brew"
        print "Install List: ${app_install_list[@]}" "${brew_install_list[@]}"
        brew install -q "${app_install_list[@]}" "${brew_install_list[@]}"
    elif (( do_debian_apt )); then
        print-header green "Installing apt packages"
        # Only add docker if it's not already installed.
        if (( do_docker )) && ! command -v docker &> /dev/null; then
            if [[ -v UBUNTU_CODENAME ]]; then
                print-header blue "Detected Ubuntu, setting up Docker apt repository"
                sudo apt update
                sudo apt install -y ca-certificates curl
                sudo install -m 0755 -d /etc/apt/keyrings
                sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                sudo chmod a+r /etc/apt/keyrings/docker.asc

                print "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                    $(. /etc/os-release && print "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            fi

            apt_install_list+=(
                docker-ce
                docker-ce-cli
                containerd.io
                docker-buildx-plugin
                docker-compose-plugin
            )
        fi

        print "Install List: ${app_install_list[@]}" "${apt_install_list[@]}"

        sudo apt update
        sudo apt install -y "${app_install_list[@]}" "${apt_install_list[@]}"
    fi

    safe-git-clone "git@github.com:matt-sorenson/dotfiles.git" "${DOTFILES}"

    # '-p' options makes all the directories that don't exist, but
    # more importantly it doesn't error if the directory already exists.
    mkdir -p "${DOTFILES}/deps"
    mkdir -p "${DOTFILES}/tmp"

    print-header blue "Setting up zsh & plugins"

    local name url
    for name url in "${(@kv)plugins}"; do
        print-header green "Setting up $name"

        if [[ "${url}" == 'shallow='* ]]; then
            url="${url#shallow=}"
            safe-git-clone --shallow "${url}" "${DOTFILES}/deps/$name"
        else
            safe-git-clone "${url}" "${DOTFILES}/deps/$name"
        fi
    done

    print-header green "Setting up zsh"
    safe-set-link "${HOME}/.zshrc"    "${DOTFILES}/zsh/zshrc.zsh"
    safe-set-link "${HOME}/.zshenv"   "${DOTFILES}/zsh/zshenv.zsh"

    print-header blue "Done setting up zsh & plugins"

    print-header green "Setting up misc dotfiles"
    safe-set-link "${HOME}/.gitconfig" "${DOTFILES}/gitconfig"

    mkdir -p "${LOCAL_DOTFILES}/bin"
    mkdir -p "${LOCAL_DOTFILES}/zsh/completions"

    if (( is_work)); then
        touch "${LOCAL_DOTFILES}/is-work"
    fi

    if [[ "${DOTFILES}/local" != "${LOCAL_DOTFILES}" ]]; then
        safe-set-link "${DOTFILES}/local" "${LOCAL_DOTFILES}"
    fi

    if ! git -C "${DOTFILES}" config --local user.email "${git_email}"; then
        print-header -w "Failed to set git user.email in ${DOTFILES}"
        print "You can change to the directory directly and try \'git config --local user.email \"you@example.com\"\'"
    fi

    if (( do_hammerspoon )); then
        print-header blue "Setting up macOS specific files"

        print-header green "Setting up hammerspoon"
        safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"

        print-header blue "macOS specific files done"
    fi

    if (( do_doomemacs )) && command -v emacs &> /dev/null; then
        print-header green "Setting up doomemacs"
        mkdir -p "${HOME}/.config"
        safe-git-clone "https://github.com/doomemacs/doomemacs" "${HOME}/.config/emacs"
        safe-set-link "${HOME}/.config/doom" "${DOTFILES}/doom"
        eval "${HOME}/.config/emacs/bin/doom install --no-env --aot"
    else
        print-header -w "emacs not found, consider installing it"
        print "Skipping doomemacs setup"
    fi

    print-header green "Setting up WS"
    export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"
    mkdir -p "${WORKSPACE_ROOT_DIR}"
    safe-set-link "${WORKSPACE_ROOT_DIR}/dotfiles" "${DOTFILES}"

    print-header green "Setting up local dotfiles complete."
    print "if any of the repos checked out above where already present you may want to run dot-check-for-update to update them."
    print "You should restart your terminal now to apply the changes."
}

main "$@"
