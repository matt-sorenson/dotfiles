autoload -Uz colors && colors

function dot-check-for-update-git() {
    local dir="${1}"
    local quiet="${2}"
    local out=0

    if [[ -d "${dir}" ]]; then
        if [[ -d "${dir}/.git" ]]; then
            print-header green "Updating ${dir}"

            pushd "${dir}" > /dev/null

            git fetch

            local branch="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
            if [[ -n "${branch}" ]]; then
                if git merge-base --is-ancestor HEAD "${branch}"; then
                    git merge "${branch}"
                elif ! git merge-base --is-ancestor "${branch}" HEAD; then
                    print-header red "Local branch has diverged from upstream: ${dir}"
                    out=1
                fi
            else
                echo "No upstream branch found for $(git rev-parse --abbrev-ref HEAD)"
                return 0
            fi

            if ! git diff --quiet --ignore-submodules HEAD; then
                print-header red "Uncommitted changes in: ${dir}"
                out=1
            fi

            # Check if branch is behind or has diverged (but NOT just ahead)
            local behind_ahead
            behind_ahead=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)

            if [[ $? -eq 0 ]]; then
                local ahead=$(echo $behind_ahead | awk '{print $1}')
                local behind=$(echo $behind_ahead | awk '{print $2}')

                if (( behind > 0 && ahead > 0 )); then
                    print-header red "Branch has diverged from upstream: ${dir}"
                    out=1
                elif (( behind > 0 )); then
                    print-header red "Branch is behind upstream: ${dir}"
                    out=1
                fi
                # Note: ahead only (ahead > 0, behind == 0) is ignored
            else
                print-header yellow "Unable to compare with upstream for: ${dir}"
                out=1
            fi

            popd > /dev/null
        elif [[ "${quiet}" -ne 1 ]]; then
            print-header yellow "Directory not a git repo: ${dir}"
        fi
    elif [[ "${quiet}" -ne 1 ]]; then
        print-header yellow "Missing Directory: ${dir}"
    fi

    return $out
}

function dot-check-for-update() {
    local -a repos_to_update
    repos_to_update=( "${DOTFILES}" "${HOME}/.fzf-tab" "${HOME}/.zsh-syntax-highlighting" )
    local out=0

    for dir in $repos_to_update; do
        if ! dot-check-for-update-git "$dir"; then
            out=1
        fi
    done

    if ! dot-check-for-update-git "${DOTFILES}/local" 1; then
        out=1
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
                out=1
            fi
        else
            print-header red "Failed to update brew."
            out=1
        fi
    fi

    if type "local-check-for-update" >> /dev/null; then
        if ! local-check-for-update; then
            out=1
        fi
    fi

    if type "${DOOMEMACS_BIN:-${HOME}/.config/emacs/bin/doom}" >> /dev/null; then
        print-header green "Updating doom emacs."

        if ! "${DOOMEMACS_BIN:-${HOME}/.config/emacs/bin/doom}" upgrade; then
            print-header red "failed to upgrade doom emacs."
            out=1
        fi
    fi

    if [[ $out -eq 0 ]]; then
        local update_filename="${DOTFILES}/tmp/dotfile-update"
        local current_time=$(date +%s)
        echo "${current_time}" >! "${update_filename}"
    fi

    return $out
}

function auto-check-for-update() {
    local fifteen_hours_in_seconds=$((60 * 60 * 15))
    local current_time=$(date +%s)
    local day_ago=$(($current_time - $fifteen_hours_in_seconds))
    local last_update=0

    local update_filename="${DOTFILES}/tmp/dotfile-update"

    if [[ -f "${update_filename}" ]]; then
        last_update=$(cat "${update_filename}")
    fi

    if [[ $last_update -lt $day_ago ]]; then
        read -q "RUN_UPDATE?It's been a while, update dotfiles? "
        echo '' # read -q doesn't output a newline
        if [[ "${RUN_UPDATE:l}" == "y" ]]; then
            dot-check-for-update;
        fi
    fi
}
