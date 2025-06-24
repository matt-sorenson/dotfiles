#! /usr/bin/env zsh

# Expect the following variables to be set:

emulate -L zsh
set -euo pipefail
setopt typeset_to_unset

if ! command -v print-header &> /dev/null; then
    autoload -Uz colors && colors

    export local_print_header=1

    print-header() {
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

safe-cp() {
    local src="${1}"
    local dest="${2}"

    if [[ -f "$dest" ]]; then
        print "${dest} already exists, skipping copy."
        return
    fi

    cp ${(q)src} ${(q)dest}
}

safe-set-link() {
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

safe-git-clone() {
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
                if [[ ! -v url ]]; then
                    url="$1"
                elif [[ ! -v dest ]]; then
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

main() {
    local app_install_list=(
        fzf
        git
        jq          # 'like sed for json'
        shellcheck
        zsh

        # These are mostly there for doomemacs but useful in general
        pandoc
        ripgrep
    )

    local -a apt_install_list=(
        emacs-nox # emacs-nox is the terminal only version of emacs
        silversearcher-ag
        fdfind
    )

    local -a brew_install_list=(
        awscli
        emacs
        fd
        the_silver_searcher
    )

    local -A plugins=(
        [fzf-tab]="shallow=https://github.com/Aloxaf/fzf-tab"
        [zsh-autosuggestions]="shallow=https://github.com/zsh-users/zsh-autosuggestions"
        [zsh-syntax-highlighting]="shallow=https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    if [[ ! -v DOTFILES ]]; then
        print-header green "\${DOTFILES} is not defined, using '${HOME}/.dotfiles'"
    fi

    export DOTFILES="${DOTFILES:-${HOME}/.dotfiles}"
    local LOCAL_DOTFILES

    local matt_email="matt@mattsorenson.com"

    local -A git_config=()

    local -A flags=(
        # macOS
        [do_brew]=0
        [do_hammerspoon]=0

        # Debian Derivitives
        [do_apt]=0

        [do_docker]=1
        [do_doomemacs]=1

        [do_local_template]=1
        [do_work]=0
    )

    local apt_specific_help=''
    local mac_specific_help=''
    case "${OSTYPE}" in
        darwin*)
            flags[do_brew]=1
            flags[do_hammerspoon]=1
            mac_specific_help="\n  --no-brew          Do not install Homebrew\n  --no-hammerspoon   Do not set up Hammerspoon"
            ;;
        linux*)
            if command -v apt &> /dev/null; then
                flags[do_apt]=1
                apt_specific_help="\n  --no-debian-apt    Do not install packages using apt"
            fi
            ;;
        *)
            print-header -w "UNKNOWN OSTYPE: ${OSTYPE}"
    esac

    local _usage="Usage: init.sh [OPTIONS]
Options:${mac_specific_help}${apt_specific_help}
  --no-local-template                   Disable initializing the local with basic files
  --work, -w                            Set up local/is_work file so hammerspoon & scripts can detect work environment
  --local-git <url>                     Use the specified git repo for local dotfiles
  --local-ref <ref>                     Use the specified reference for local dotfiles
  --git-local-email                     Email to  set in the local/gitconfig file
  --git-local-name                      name to  set in the local/gitconfig file

  --git-dotfiles-email                  Email to use in the \${DOTFILES}/.git/config file
  --git-dotfiles-name                   Name to use in the \${DOTFILES}/.git/config file

  --no-brew                             Do not install Homebrew
  --no-hammerspoon                      Do not set up Hammerspoon
  --no-debian-apt                       Do not install packages using apt
  --no-docker                           Do not install Docker
  --no-doom, --no-doomemacs             Do not install Doom Emacs

  --no-plugin-fzf-tab                   Do not install fzf-tab plugin
  --no-plugin-zsh-syntax-highlighting   Do not install zsh-syntax-highlighting plugin

  --plugin <name=[shallow=]url>         Add a custom plugin to install
        Plugins added here will be automatically updated with the dot-check-for-update script
        You'll need to manually source/init zsh plugins (that aren't 'local' or in the default list).
        Shallow flags the repo to be cloned with --depth 1, which is useful for large repos.

  --help, -h                            Show this help message"
    unset mac_specific_help apt_specific_help


    while (( $# )); do
        case "$1" in
            --no-local-template)
                flags[do_local_template]=0
                ;;
            --no-plugin-*)
                local key="${1#--no-plugin-}"

                if [[ ! -v plugins[$key] ]]; then
                    print-header -e "Unknown plugin: $1"
                    print "${_usage}"
                    return 1
                fi

                unset "plugins[$key]"
                ;;
            --no-*)
                local key="do_${${1#--no-}//-/_}"
                key="${key/%doom/doomemacs}"

                if [[ ! -v flags[$key] ]]; then
                    print-header -e "Unknown flag: $1"
                    print "${_usage}"
                    return 1
                fi

                flags[$key]=0
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
                    if [[ -v LOCAL_DOTFILES ]]; then
                        print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                        return 1
                    fi

                    LOCAL_DOTFILES="${DOTFILES}/deps/local"
                fi
                ;;
            --local-git)
                shift
                if (( $# == 0 )); then
                    print-header -e "--local-git requires a value"
                    return 1
                elif [[ -v LOCAL_DOTFILES ]]; then
                    print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                    return 1
                fi

                plugins[local]="$1"
                LOCAL_DOTFILES="${DOTFILES}/deps/local"
                ;;
            --local-ref)
                shift
                if (( $# == 0 )); then
                    print-header -e "--local-ref requires a value"
                    return 1
                elif [[ -v LOCAL_DOTFILES ]]; then
                    local new="${DOTFILES}/local.$1"
                    print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '${new}'"
                    return 1
                fi
                LOCAL_DOTFILES="${DOTFILES}/local.$1"
                ;;
            --help|-h)
                print "${_usage}"
                return 0
                ;;
            --local-git-email)
                shift
                if (( $# == 0 )); then
                    print-header -e "--local-git-email requires a value"
                    return 1
                elif [[ -v git_config[local_email] ]]; then
                    print-header -e "--local-git-email already set. Existing: ${git_config[local_email]}, New: $1"
                fi
                git_config[local_email]="$1"
                ;;
            --git-local-name)
                shift
                if (( $# == 0 )); then
                    print-header -e "--git-local-name requires a value"
                    return 1
                elif [[ -v git_config[local_name] ]]; then
                    print-header -e "--git-local-name already set. Existing: ${git_config[local_name]}, New: $1"
                fi
                git_config[local_name]="$1"
                ;;
            --git-dotfiles-email)
                if (( $# > 1 )); then
                    print-header -e "$1 requires a value"
                    return 1
                elif [[ -v git_config[dir_dotfiles_email] ]]; then
                    print-header -e "$1 already set. Existing: ${git_config[dir_dotfiles_email]}, New: $2"
                fi
                shift
                git_config[dir_dotfiles_email]="$1"
                ;;
            --git-dotfiles-matt)
                if [[ -v git_config[dir_dotfiles_email] ]]; then
                    print-header -e "--git-dotfiles-email already set. Existing: ${git_config[dir_dotfiles_email]}, New: ${matt_email}"
                elif [[ -v git_config[dir_dotfiles_name] ]]; then
                    print-header -e "--git-dotfiles-name already set. Existing: ${git_config[dir_dotfiles_name]}, New: ${matt_email}"
                fi

                git_config[dir_dotfiles_email]="${matt_email}"
                git_config[dir_dotfiles_name]="Matt Sorenson"
                ;;
            --git-dotfiles-name)
                if (( $# > 1 )); then
                    print-header -e "$1 requires a value"
                    return 1
                elif [[ -v git_config[dir_dotfiles_name] ]]; then
                    print-header -e "$1 already set. Existing: ${git_config[dir_dotfiles_name]}, New: $2"
                fi
                shift
                git_config[dir_dotfiles_name]="$1"
                ;;
            -w)
                argv+=('--work')
                ;;
            *)
                local key="do_${${1#--}//-/_}"
                key="${key/%doom/doomemacs}"
                key="${key/%do_work/do_local_work}"

                if [[ ! -v flags[$key] ]]; then
                    print-header -e "Unknown flag: $1"
                    print "${_usage}"
                    return 1
                fi

                flags[$key]=1
                ;;
        esac
        shift
    done

    if command -v locale-gen &> /dev/null; then
        sudo locale-gen en_US en_US.UTF-8
    fi

    if (( flags[do_brew] )); then
        if ! command -v brew &> /dev/null; then
            print-header green "Installing Homebrew"

            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        if (( flags[do_docker] )); then
            brew_install_list+=( docker docker-compose )
        fi

        print-header green "installing items from brew"
        print "Install List: ${(q)app_install_list[@]} ${(q)brew_install_list[@]}"
        brew install -q ${(q)app_install_list[@]} ${(q)brew_install_list[@]}
    elif (( flags[do_apt] )); then
        print-header green "Installing apt packages"
        # Only add docker if it's not already installed.
        if (( flags[do_docker] )) && ! command -v docker &> /dev/null; then
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

        print "Install List: ${(q)app_install_list[@]} ${(q)apt_install_list[@]}"

        sudo apt update
        sudo apt install -y ${(q)app_install_list[@]} ${(q)apt_install_list[@]}
    fi

    mkdir -p ~/bin
    if [[ -f /usr/share/doc/git/contrib/diff-highlight/diff-highlight ]]; then
        cp /usr/share/doc/git/contrib/diff-highlight/diff-highlight ~/bin/diff-highlight
    elif command -v brew &> /dev/null; then
        local git_brew_root
        if git_brew_root="$(brew --prefix git)"; then
            if [[ -f "${git_brew_root}/share/git-core/contrib/diff-highlight/diff-highlight" ]]; then
                cp "${git_brew_root}/share/git-core/contrib/diff-highlight/diff-highlight" ~/bin/diff-highlight
            fi
        fi
    fi

    if [[ -f ~/bin/diff-highlight ]]; then
        chmod u+wrx ~/bin/diff-highlight # give user read/write/execute
        chmod +rx ~/bin/diff-highlight   # give everyone read/execute
    else
        print-header red "Failed to find diff-highlight"
    fi

    if command -v fdfind &> /dev/null; then
        ln -s "$(which fdfind)" "${HOME}/bin/fd"
    fi

    safe-git-clone "git@github.com:matt-sorenson/dotfiles.git" "${DOTFILES}"
    # print-header from the dotfiles is more robust so :shrug:
    unset -f print-header
    PATH="${DOTFILES}/bin:${PATH}"

    # '-p' options makes all the directories that don't exist, but
    # more importantly it doesn't error if the directory already exists.
    mkdir -p "${DOTFILES}/deps"
    mkdir -p "${DOTFILES}/tmp"

    print-header -i 2 'Setting up $DOTFILES githoooks to $DOTFILES/.githooks'
    git -C "${DOTFILES}/" config core.hooksPath "${DOTFILES}/githooks"

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

    if [[ -v LOCAL_DOTFILES ]]; then
        if [[ "${DOTFILES}/local" != "${LOCAL_DOTFILES}" ]]; then
            safe-set-link "${DOTFILES}/local" "${LOCAL_DOTFILES}"
        fi
    fi

    if (( flags[do_local_template] )); then
        print-header green "Setting up local based off of template"

        mkdir -p "${DOTFILES}/local/bin"
        mkdir -p "${DOTFILES}/local/zsh/completions"

        touch "${DOTFILES}/local/zsh/zshenv.zsh"
        touch "${DOTFILES}/local/zsh/zshrc.zsh"
        touch "${DOTFILES}/local/gitconfig"

        if (( flags[do_hammerspoon] )); then
            safe-cp "${DOTFILES}/templates/config-home-assistant.lua" "${DOTFILES}/local/config-home-assistant.lua"
            safe-cp "${DOTFILES}/templates/pr-teams.lua" "${DOTFILES}/local/pr-teams.lua"
        fi
    fi

    if (( flags[do_work] )); then
        touch "${DOTFILES}/local/is-work"
    fi

    if [[ -v git_config[dir_dotfiles_email] ]]; then
        if ! git -C "${DOTFILES}" config --local user.email "${git_config[dir_dotfiles_email]}"; then
            print-header -w "Failed to set git user.email in ${DOTFILES}"
            print "You can change to the directory directly and try \'git config --local user.email \"you@example.com\"\'"
        fi
    fi
    if [[ -v git_config[dir_dotfiles_name] ]]; then
        if ! git -C "${DOTFILES}" config --local user.name "${git_config[dir_dotfiles_name]}"; then
            print-header -w "Failed to set git user.name in ${DOTFILES}"
            print "You can change to the directory directly and try \'git config --local user.name \"First Last\"\'"
        fi
    fi

    if [[ -f "${DOTFILES}/local/gitconfig" ]]; then
        if [[ -v git_config[local_email] ]]; then
            if ! git config --file "${DOTFILES}/local/gitconfig" user.email "$git_config[local_email]"; then
                print-header -w "Failed to set user.email in ${DOTFILES}/local/gitconfig"
            fi
        fi
        if [[ -v git_config[local_name] ]]; then
            if ! git config --file "${DOTFILES}/local/gitconfig" user.name "$git_config[local_name]"; then
                print-header -w "Failed to set user.name in ${DOTFILES}/local/gitconfig"
            fi
        fi
    fi

    if (( flags[do_hammerspoon] )); then
        print-header green "Setting up hammerspoon"
        safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"
    fi

    if (( flags[do_doomemacs] )); then
        if command -v emacs &> /dev/null; then
            print-header green "Setting up doomemacs"
            mkdir -p "${HOME}/.config"
            safe-git-clone "https://github.com/doomemacs/doomemacs" "${HOME}/.config/emacs"
            safe-set-link "${HOME}/.config/doom" "${DOTFILES}/doom"
            eval "${HOME}/.config/emacs/bin/doom install --no-env --aot"
        else
            print-header -w "emacs not found, consider installing it"
            print "Skipping doomemacs setup"
        fi
    fi

    print-header green "Setting up WS"
    export WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR:-${HOME}/ws}"
    mkdir -p "${WORKSPACE_ROOT_DIR}"
    safe-set-link "${WORKSPACE_ROOT_DIR}/dotfiles" "${DOTFILES}"
    print "WORKSPACE_ROOT_DIR=${WORKSPACE_ROOT_DIR}"

    print-header green "Setting up dotfiles complete."
    print "if any of the repos checked out above where already present you may want to run dot-check-for-update to update them."
    print "You should restart your terminal now to apply the changes."
}

main "$@"
