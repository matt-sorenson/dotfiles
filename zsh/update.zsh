autoload -Uz colors && colors

function dot-check-for-update-git() {
    local dir="${1}"
    local QUIET="${2}"
    local OUT=0

    if [[ -d "${dir}" ]]; then
        if [[ -d "${dir}/.git" ]]; then
            print-header green "Updating ${dir}"

            pushd "${dir}" > /dev/null

            git fetch

            local BRANCH="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
            if [[ -n "${BRANCH}" ]]; then
                if git merge-base --is-ancestor HEAD "${BRANCH}"; then
                    git merge "${BRANCH}"
                elif ! git merge-base --is-ancestor "${BRANCH}" HEAD; then
                    print-header red "Local branch has diverged from upstream: ${dir}"
                    OUT=1
                fi
            else
                print-header yellow "No upstream branch found for $(git rev-parse --abbrev-ref HEAD)"
            fi

            if ! git diff --quiet --ignore-submodules HEAD; then
                print-header red "Uncommitted changes in: ${dir}"
                OUT=1
            fi

            # Check if branch is behind or has diverged (but NOT just ahead)
            local behind_ahead
            behind_ahead=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)

            if [[ $? -eq 0 ]]; then
                local ahead=$(echo $behind_ahead | awk '{print $1}')
                local behind=$(echo $behind_ahead | awk '{print $2}')

                if (( behind > 0 && ahead > 0 )); then
                    print-header red "Branch has diverged from upstream: ${dir}"
                    OUT=1
                elif (( behind > 0 )); then
                    print-header red "Branch is behind upstream: ${dir}"
                    OUT=1
                fi
                # Note: ahead only (ahead > 0, behind == 0) is ignored
            else
                print-header yellow "Unable to compare with upstream for: ${dir}"
                OUT=1
            fi

            popd > /dev/null
        elif [[ "${QUIET}" -ne 1 ]]; then
            print-header yellow "Directory not a git repo: ${dir}"
        fi
    elif [[ "${QUIET}" -ne 1 ]]; then
        print-header yellow "Missing Directory: ${dir}"
    fi

    return $OUT
}

function dot-check-for-update() {
    local -a REPOS_TO_UPDATE
    REPOS_TO_UPDATE=( "${DOTFILES}" "${HOME}/.fzf-tab" "${HOME}/.zsh-syntax-highlighting" )
    local OUT=0

    for dir in $REPOS_TO_UPDATE; do
        if ! dot-check-for-update-git "$dir"; then
            OUT=1
        fi
    done

    if ! dot-check-for-update-git "${DOTFILES}/local" 1; then
        OUT=1
    fi

    if type "hs" >> /dev/null; then
        print-header green "Reloading hammerspoon"
        hs -c "hs.reload()"
    fi

    if type "brew" >> /dev/null; then
        print-header green "Updating brew."

        if brew update; then
            if ! brew upgrade; then
                print-header red "Failed to upgrade brew."
                OUT=1
            fi
        else
            print-header red "Failed to update brew."
            OUT=1
        fi
    fi

    if type "local-check-for-update" >> /dev/null; then
        if ! local-check-for-update; then
            OUT=1
        fi
    fi

    if type "${DOOMEMACS_BIN:-${HOME}/.config/emacs/bin/doom}" >> /dev/null; then
        print-header green "Updating doom emacs."

        if ! "${DOOMEMACS_BIN:-${HOME}/.config/emacs/bin/doom}" upgrade; then
            print-header red "failed to upgrade doom emacs."
            OUT=1
        fi
    fi

    if [[ $OUT -eq 0 ]]; then
        local UPDATE_FILENAME="${DOTFILES}/tmp/dotfile-update"
        local CURRENT_TIME=$(date +%s)
        echo "${CURRENT_TIME}" >! "${UPDATE_FILENAME}"
    fi

    return $OUT
}

function auto-check-for-update() {
    local FIFTEEN_HOURS_IN_SECONDS=$((60 * 60 * 15))
    local CURRENT_TIME=$(date +%s)
    local DAY_AGO=$(($CURRENT_TIME - $FIFTEEN_HOURS_IN_SECONDS))
    local LAST_UPDATE=0

    local UPDATE_FILENAME="${DOTFILES}/tmp/dotfile-update"

    if [[ -f "${UPDATE_FILENAME}" ]]; then
        LAST_UPDATE=$(cat "${UPDATE_FILENAME}")
    fi

    if [[ $LAST_UPDATE -lt $DAY_AGO ]]; then
        read -q "RUN_UPDATE?It's been a while, update dotfiles? "
        echo '' # read -q doesn't output a newline
        if [[ "${RUN_UPDATE:l}" == "y" ]]; then
            dot-check-for-update;
        fi
    fi
}
