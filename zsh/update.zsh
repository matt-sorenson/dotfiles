autoload -Uz colors && colors

print-header(){
    local color="$fg_bold[${1}]"
    local header="================================================================================"
    shift
    local message="${@}"
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}

dot-check-for-update() {
    local -a REPOS_TO_UPDATE
    REPOS_TO_UPDATE=( "${DOTFILES}" "${DOTFILES}/local" "${HOME}/.emacs.d" "${HOME}/.zprezto" )
    local OUT=0

    for dir in $REPOS_TO_UPDATE; do
        if [[ -d "${dir}" ]] && [[ -d "${dir}/.git" ]]; then
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
        else
            print-header yellow "Missing Directory: ${dir}"
        fi
    done

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

    if [[ $OUT -eq 0 ]]; then
        echo $CURRENT_TIME >! "${UPDATE_FILENAME}"
    fi

    return $OUT
}

auto-check-for-update() {
    local FIFTEEN_HOURS_IN_SECONDS=$((60 * 60 * 15))
    local CURRENT_TIME=$(date +%s)
    local DAY_AGO=$((${CURRENT_TIME} - ${FIFTEEN_HOURS_IN_SECONDS}))
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
