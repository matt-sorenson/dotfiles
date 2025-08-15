#! /usr/bin/env zsh

# Expect the following variables to be set:

emulate -L zsh
set -euo pipefail
setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
unsetopt short_loops

if ! command -v print-header &> /dev/null; then
    autoload -Uz colors && colors

    print-header() {
        emulate -L zsh
        set -uo pipefail
        setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
        unsetopt short_loops

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
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    local src="${1}"
    local dest="${2}"

    if [[ -f "$dest" ]]; then
        print "${dest} already exists, skipping copy."
        return
    fi

    cp ${(q)src} ${(q)dest}
}

safe-set-link() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

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
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

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

ssh-file-locked-down() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    local ssh_key="$1"
    local perms="$(stat -f %Lp "${ssh_key}" 2> /dev/null || stat -c %a "${ssh_key}" 2> /dev/null)"
    local group_write=$(( (perms / 10) % 10 ))
    local other_write=$(( perms % 10 ))
    if (( group_write & 2 || other_write & 2 )); then
        print-header -w "SSH key ${ssh_key} has insecure permissions (${perms}), Fixing."
        chmod u+rw,go-w "${ssh_key}"
    fi
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    local app_install_list=(
        fzf
        git
        jq          # 'like sed for json'
        shellcheck
        ssh-askpass
        zsh

        # These are mostly there for doomemacs but useful in general
        fontconfig
        pandoc
        ripgrep
    )

    local -a apt_install_list=(
        emacs-nox # emacs-nox is the terminal only version of emacs
        fdfind
        silversearcher-ag
    )

    local -a brew_install_list=(
        awscli
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

    local matt_username=matt
    # Splitting this so it's harder for scrapers
    local matt_domain=mattsorenson.com
    local matt_email="${matt_username}@${matt_domain}"

    local -A git_config=()
    local -A ssh_config=()

    local -A flags=(
        # The macOs/Debian specific flags are added in the case statement below

        [docker]=1
        [doom]=1

        [local_template]=1
        [work]=0

        [ssh]=1
    )

    local apt_specific_help=''
    local mac_specific_help=''
    case "${OSTYPE}" in
        darwin*)
            flags[brew]=1
            flags[hammerspoon]=1
            flags[ssh_keychain]=1
            flags[base-emacs]=0
            mac_specific_help="
  --no-brew          Do not install Homebrew
  --no-hammerspoon   Do not set up Hammerspoon
  --no-ssh-keychain  Do not set up the ssh key into the macOS keychain
  --base-emacs       Install base emacs instead of emacs-plus"
            ;;
        linux*)
            if command -v apt &> /dev/null; then
                flags[apt]=1
                apt_specific_help="\n  --no-apt.             Do not install packages using apt"
            fi
            ;;
        *)
            print-header -w "UNKNOWN OSTYPE: ${OSTYPE}"
    esac

    local _usage="Usage: init.sh [OPTIONS]
Options:${mac_specific_help}${apt_specific_help}
  --no-local-template   Disable initializing the local with basic files
  --work, -w            Set up local/is_work file so hammerspoon & scripts can detect work environment
  --local-git <url>     Use the specified git repo for local dotfiles
  --local-ref <ref>     Use the specified reference for local dotfiles
  --git-local-email     Email to  set in the local/gitconfig file
  --git-local-name      name to  set in the local/gitconfig file
  --no-local-template   If local is created due to not being specified as a plugin or a ref or git repo
                        then this flag disables creating a bare bones set of files.

  --ssh-key-type <type> Type of SSH key to generate (defaults to default from create-ssh-key)

  --git-dotfiles-email  Email to use in the \${DOTFILES}/.git/config file
  --git-dotfiles-name   Name to use in the \${DOTFILES}/.git/config file

  --no-ssh              Do not set up SSH
  --no-brew             Do not install Homebrew
  --no-hammerspoon      Do not set up Hammerspoon
  --no-apt              Do not install packages using apt
  --no-docker           Do not install Docker
  --no-doom             Do not install Doom Emacs

  --no-plugin-fzf-tab                   Do not install fzf-tab plugin
  --no-plugin-zsh-syntax-highlighting   Do not install zsh-syntax-highlighting plugin

  --plugin <name=[shallow=]url>         Add a custom plugin to install
        Plugins added here will be automatically updated with the dot-check-for-update script
        You'll need to manually source/init zsh plugins (that aren't 'local' or in the default list).
        Shallow flags the repo to be cloned with --depth 1, which is useful for large repos.

  --ssh-key-type <type>    Type of SSH key to generate, (default: 'ed25519')

  --help, -h                            Show this help message"
    unset mac_specific_help apt_specific_help

    while (( $# )); do
        case "$1" in
            --help|-h)
                print "${_usage}"
                return 0
                ;;
            --no-local-template)
                flags[local_template]=0
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
            --plugin|-p)
                shift
                local plugin_name plugin_url

                if (( ! $# )); then
                    print-header -e "--plugin requires a value"
                    print "${_usage}"
                    return 1
                fi

                if [[ "$1" =~ '^github:(.*)/(.*)$' ]]; then

                elif [[ "$1" =~ '^(shallow=)?(github\.com/|https://github\.com/|git@github\.com:/)([^/]+)/([^/?#(.git$)]+?)(\.git)?/?$' ]]; then
                    plugin_name="${match[4]%.git}"
                    plugin_url="$1"
                elif [[ "$1" == *=* ]]; then
                    # Format: name=url
                    plugin_name="${1%%=*}"
                    plugin_url="${1#*=}"

                    if [[ -z "${plugin_name}" || -z "${plugin_url}" ]]; then
                        print-header -e "--plugin argument must include both name and URL"
                        return 1
                    fi
                else
                    print-header -e "invalid --plugin"
                    print "must be in one of the following formats"
                    print "  <name>=[shallow=]<url>"
                    print "  [shallow=][https://]github.com/<user>/<reponame>[.git]"
                    print "  [shallow=]git@github.com:/<user>/<reponame>[.git]"
                    return 1
                fi

                plugins["${plugin_name}"]="${plugin_url}"

                if [[ ${plugin_name} == 'local' ]]; then
                    if [[ -v LOCAL_DOTFILES ]]; then
                        print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                        return 1
                    fi

                    LOCAL_DOTFILES="${DOTFILES}/plugins/local"
                fi
                ;;
            --local-*)
                if (( $# < 2 )); then
                    print-header -e "$1 requires a value"
                    return 1
                elif [[ -v LOCAL_DOTFILES ]]; then
                    print-header -e "\$LOCAL_DOTFILES set multiple times. Existing: '${LOCAL_DOTFILES}', New: '$1'"
                    return 1
                fi

                if [[ $1 == --local-git ]]; then
                    plugins[local]="$2"
                    LOCAL_DOTFILES="${DOTFILES}/plugins/local"
                elif [[ $1 == --local-ref ]]; then
                    LOCAL_DOTFILES="${DOTFILES}/local.$1"
                else
                    print-header -e "Unknown Header $1"
                    print "${_usage}"
                    return 1
                fi
                ;;
            --git-dotfiles-matt)
                # Since this is just an an alias lets just throw the other flags
                # on the the end of the parameters list so we don't need to dupe
                # the validation.
                argv+=(
                    --git-dotfiles-email "${matt_email}"
                    --git-dotfiles-name "Matt Sorenson"
                )
                ;;
            --git-*)
                local key="${${${1#--git-}#dotfiles-}#local-}"

                if [[ "$key" != name && "$key" != email ]]; then
                    print-header -e "Unknown options $1"
                    print "${_usage}"
                    return 1
                fi

                if [[ "$1" == -local- ]]; then
                    key="local_${key}"
                elif [[ "$1" == -dotfiles- ]]; then
                    key="dir_dotfiles_${key}"
                else
                    print-header -e "Unknown flag: $1"
                    print "${_usage}"
                    return 1
                fi


                if (( $# < 2 )); then
                    print-header -e "$1 requires a value"
                    return 1
                elif [[ -v git_config[$key] ]]; then
                    print-header -e "$1 already set. Existing: ${git_config[$key]}, New: $2"
                fi
                shift
                git_config[$key]="$1"
                ;;
            -w) flags[work]=1 ;;
            *)
                local key="${${1#--}//-/_}"
                key="${key/%local_work/work}"

                local -i enabled=1
                if [[ "$key" == no_* ]]; then
                    key="${key#no_}"
                    enabled=0
                fi

                if [[ -v flags[$key] ]]; then
                    flags[$key]=$enabled
                elif [[ "$key" == 'ssh_key_type' ]]; then
                    if (( $# < 2 )); then
                        print-header -e "$1 requires a value"
                        return 1
                    fi
                    shift

                    ssh_config[type]="$1"
                else
                    print-header -e "Unknown flag: $1"
                    print "${_usage}"
                    return 1
                fi
                ;;
        esac
        shift
    done

    if command -v locale-gen &> /dev/null; then
        sudo locale-gen en_US en_US.UTF-8
    fi

    if (( flags[brew] )); then
        if ! command -v brew &> /dev/null; then
            print-header green "Installing Homebrew"

            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        if (( flags[docker] )); then
            brew_install_list+=( docker docker-compose )
        fi

        if (( flags[base-emacs] )); then
            brew_install_list+=( emacs )
        else
            brew tap d12frosted/emacs-plus
            brew_install_list+=( emacs-plus --without-cocoa )
        fi

        brew tap theseal/ssh-askpass

        app_install_list+=( "${brew_install_list[@]}" )

        local -a bulk_install_list=()
        local -a single_install_list=()
        local item
        for item in "${app_install_list[@]}"; do
            if [[ "$item" == *' '* ]]; then
                bulk_install_list+=( "$item" )
            else
                single_install_list+=( "$item" )
            fi
        done

        print-header green "installing items from brew"
        local MATCH MBEGIN MEND
        print "Install List: ${(@)app_install_list//(#m)*/\"$MATCH\"}"

        if (( ${#bulk_install_list[@]} > 0 )); then
            brew install "${bulk_install_list[@]}"
        fi

        if (( ${#single_install_list[@]} > 0 )); then
            for item in "${single_install_list[@]}"; do
                # Explicitly unquoted as spaces indicate multiple arguments
                brew install ${item}
            done
        fi

    elif (( flags[apt] )); then
        print-header green "Installing apt packages"
        # Only add docker if it's not already installed.
        if (( flags[docker] )) && ! command -v docker &> /dev/null; then
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

    # Use https here cause ssh may not have been setup yet.
    safe-git-clone "https://github.com/matt-sorenson/dotfiles.git" "${DOTFILES}"
    unset -f print-header
    source "${DOTFILES}/zsh/zshenv.zsh"
    source "${DOTFILES}/zsh/zshrc.zsh"

    print-header blue 'Setting up $DOTFILES githoooks to $DOTFILES/.githooks'
    git -C "${DOTFILES}" config core.hooksPath "${DOTFILES}/githooks"

    if (( flags[ssh] )); then
        print-header green "Setting up SSH"

        if [[ -r "${HOME}/.ssh/id_"* ]]; then
            # Check that SSH keys have secure permissions (only owner can write)
            local ssh_key
            for ssh_key in "${HOME}/.ssh/id_"*; do
                ssh-file-locked-down "${ssh_key}"
            done
            print-header green "SSH keys already exist, skipping key generation"
        else
            local ssh_key_args=()
            if (( !flags[ssh_keychain] )); then
                ssh_key_args+=(--no-keychain)
            fi
            if [[ -v ssh_config[type] ]]; then
                ssh_key_args+=(--type "${ssh_config[type]}")
            fi

            create-ssh-key "${ssh_key_args[@]}"
        fi
    fi

    # Update the origin to use the ssh url instead of https
    git -C "${DOTFILES}" remote set-url origin git@github.com:matt-sorenson/dotfiles.git

    # '-p' option makes all the directories that don't exist, but
    # more importantly it doesn't error if the directory already exists.
    mkdir -p "${DOTFILES}/plugins"
    mkdir -p "${DOTFILES}/tmp"

    print-header blue "Setting up zsh & plugins"

    local name url
    for name url in "${(@kv)plugins}"; do
        print-header green "Setting up $name"

        if [[ "${url}" == 'shallow='* ]]; then
            url="${url#shallow=}"
            safe-git-clone --shallow "${url}" "${DOTFILES}/plugins/$name"
        else
            safe-git-clone "${url}" "${DOTFILES}/plugins/$name"
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

    if (( flags[local_template] )); then
        print-header green "Setting up local based off of template"

        mkdir -p "${DOTFILES}/local/bin"
        mkdir -p "${DOTFILES}/local/zsh"
        mkdir -p "${DOTFILES}/local/zsh/functions"

        touch "${DOTFILES}/local/zsh/zshenv.zsh"
        touch "${DOTFILES}/local/zsh/zshrc.zsh"
        touch "${DOTFILES}/local/gitconfig"

        if (( flags[hammerspoon] )); then
            safe-cp "${DOTFILES}/templates/config-home-assistant.lua" "${DOTFILES}/local/config-home-assistant.lua"
            safe-cp "${DOTFILES}/templates/pr-teams.lua" "${DOTFILES}/local/pr-teams.lua"
        fi
    fi

    if (( flags[work] )); then
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

    if (( flags[hammerspoon] )); then
        print-header green "Setting up hammerspoon"
        safe-set-link "${HOME}/.hammerspoon" "${DOTFILES}/hammerspoon"
    fi

    if (( flags[doom] )); then
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
