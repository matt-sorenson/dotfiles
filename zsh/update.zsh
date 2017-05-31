autoload -Uz colors && colors

check_for_update() {
    local print_header(){
        local color="$fg_bold[${1}]"
        local header="================================================================================"
        shift
        local message="${@}"
        echo "$color${header}\n= ${message}\n${header}$reset_color"
    }

    local original_dir=$(pwd)

    local REPOS_TO_UPDATE=("${DOTFILES}" "${DOTFILES}/local" "${HOME}/.emacs.d" "${HOME}/.zprezto")
    local OUT=0

    for dir in $REPOS_TO_UPDATE; do
        if [[ -d "${dir}" ]] && [[ -d "${dir}/.git" ]]; then
            print_header green "Updating ${dir}"

            cd "${dir}"

            git fetch
            local BRANCH=$(git status | grep -i "your branch is" | perl -pe "s|Your branch is behind '(.*?)' by \d* commit, and can be fast-forwarded.|\1|")

            if [[ -z "${BRANCH// }" ]]; then
                git merge "$BRANCH"
            fi

            git status | grep "Your branch is up-to-date" > /dev/null
            if [[ $? -ne 0 ]]; then
                print_header red "Repo could not automaticly merge: ${dir}"
                OUT=1
            fi
        else
            print_header yellow "Missing Directory: ${dir}"
        fi
    done

    cd "${original_dir}"

    return $OUT
}

auto_check_for_update() {
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
            echo
            check_for_update

            if [[ $? -eq 0 ]]; then
                echo $CURRENT_TIME >! "${UPDATE_FILENAME}"
            fi
        fi
    fi
}
