autoload -Uz colors && colors

print-header(){
    local color="$fg_bold[${1}]"
    local header="================================================================================"
    shift
    local message="${@}"
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}

local-check-for-update() {}

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

            git status | grep "Your branch is up[ -]to[ -]date" > /dev/null
            if [[ $? -ne 0 ]]; then
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
        brew update

        if [[ $? -eq 0 ]]; then
            brew upgrade

            if [[ $? -ne 0 ]]; then
                print-header red "Failed to upgrade brew."
                OUT=1
            fi
        else
            print-header red "Failed to update brew."
            OUT=1
        fi
    fi

    local-check-for-update
    if [[ $? -ne 0 ]]; then
        OUT=1
    fi

    return $OUT
}

auto-check-for-update() {
    local WEEK_IN_SECONDS=$((7 * 60 * 60 * 24))
    local CURRENT_TIME=$(date +%s)
    local WEEK_AGO=$((${CURRENT_TIME} - ${WEEK_IN_SECONDS}))
    local LAST_UPDATE=0

    local UPDATE_FILENAME="${DOTFILES}/tmp/dotfile-update"

    if [[ -f "${UPDATE_FILENAME}" ]]; then
        LAST_UPDATE=$(cat "${UPDATE_FILENAME}")
    fi

    if [[ $LAST_UPDATE -lt $WEEK_AGO ]]; then
        read -q "RUN_UPDATE?It's been over a week, update dotfiles? "
        if [ 'y' = "$RUN_UPDATE" ]; then
            dot-check-for-update

            if [[ $? -eq 0 ]]; then
                echo $CURRENT_TIME >! "${UPDATE_FILENAME}"
            fi
        fi
    fi
}
