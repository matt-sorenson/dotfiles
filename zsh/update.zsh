autoload -Uz colors && colors

dot-check-for-update-git() {
    local dir="$1"
    local QUIET="$2"
    local OUT=0

    if [[ -d "${dir}" ]]; then
        if [[ -d "${dir}/.git" ]] then
            print-header green "Updating ${dir}"

            pushd "${dir}" > /dev/null

            git fetch
            local BRANCH_STATUS="$(git status | grep -i "your branch is")"
            if grep "and can be fast-forwarded" <<< "${BRANCH_STATUS}" &> /dev/null; then
                local BRANCH="$(perl -pe "s|Your branch is behind '(.*?)' by \d* commit(s){0,1}, and can be fast-forwarded.|\1|" <<< "${BRANCH_STATUS}")"

                if [[ -n "${BRANCH// }" ]]; then
                    git merge "$BRANCH"
                fi
            fi

            if ! git status | grep "Your branch is up[ -]to[ -]date" > /dev/null; then
                print-header red "Repo could not automaticly merge: ${dir}"
                OUT=1
            fi

            popd > /dev/null
        elif [[ "$QUIET" -ne 1 ]]; then
            print-header yellow "Directory not a git repo: ${dir}"
        fi
    elif [[ "$QUIET" -ne 1 ]]; then
        print-header yellow "Missing Directory: ${dir}"
    fi

    return $OUT
}

dot-check-for-update() {
    local -a REPOS_TO_UPDATE
    REPOS_TO_UPDATE=( "${DOTFILES}" "${HOME}/.zprezto" )
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

    if type ~/.config/emacs/bin/doom >> /dev/null; then
        print-header green "Updating doom emacs."

        if ! ~/.config/emacs/bin/doom upgrade; then
            print-header red "failed to upgrade doom emacs."
            OUT=1
        fi
    fi

    if [[ $OUT -eq 0 ]]; then
        local UPDATE_FILENAME="${DOTFILES}/tmp/dotfile-update"
        local CURRENT_TIME=$(date +%s)
        echo $CURRENT_TIME >! "${UPDATE_FILENAME}"
    fi

    return $OUT
}

auto-check-for-update() {
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
        if [ 'y' = "$RUN_UPDATE" ]; then
            dot-check-for-update;
        fi
    fi
}
