# Heavily modified 'Agnoster' Theme

setopt prompt_subst

zmodload zsh/datetime
zmodload zsh/regex

typeset -g _theme_ender_current_bg='NONE'
typeset -g _theme_ender_seperator=''

_theme-ender-bg-color() {
    print -n "%K{$1}"
}

_theme-ender-fg-color() {
    print -n "%F{$1}"
}

_theme-ender-start-segment() {
    _theme-ender-bg-color "$1"
    local msg=' '
    if [[ "${_theme_ender_current_bg}" != 'NONE' && "$1" != "${_theme_ender_current_bg}" ]]; then
        _theme-ender-fg-color "${_theme_ender_current_bg}"
        msg="${_theme_ender_seperator} "
    fi

    print -n "${msg}"

    _theme-ender-fg-color "$2"
    _theme_ender_current_bg="$1"
}

_theme-ender-segment-print() {
    _theme-ender-start-segment "$1" "$2"

    # Remove trailing spaces from the input string to avoid duplicates.
    print -n "${3%%[[:space:]]##} "
}

_dot-prompt-segment() {
    _theme-ender-segment-print "$@"
}

_theme-ender-end-segment() {
    if [[ -n "${_theme_ender_current_bg}" ]]; then
        _theme-ender-fg-color ${_theme_ender_current_bg}
        print -n "%k"
    fi
    print -n "%k%f"
    _theme_ender_current_bg='NONE'
}

_theme-ender-seg-last-call-status() {
    theme run-segment pre-last-call-status

    if (( _theme_prev_exit_code )); then
        _theme-ender-segment-print red black '$_theme_crossout'
    else
        _theme-ender-segment-print green black '$_theme_checkmark'
    fi

    theme run-segment post-last-call-status
}

_theme-ender-seg-dir() {
    emulate -L zsh

    theme run-segment pre-dir

    local working_dir="$(pwd)"
    local msg="%~"

    if [[ "${working_dir}" = "${WORKSPACE_ROOT_DIR}"/* ]]; then
        if [[ "${working_dir#${WORKSPACE_ROOT_DIR}}" =~ '/([^/]+)(.*)' ]]; then
            _theme-ender-segment-print yellow black "ws"
            _theme-ender-segment-print cyan black "${match[1]}"
            msg="${match[2]#?}"
        fi
    fi

    _theme-ender-segment-print blue black "${msg}"

    theme run-segment post-dir
}

_theme-ender-seg-time() {
    theme run-segment pre-time

    TZ='${_theme_timezone}' _theme-ender-segment-print black default "$(date +"%H:%M:%S")"

    theme run-segment post-time
}

_theme-ender-seg-git-info() {
    theme run-segment pre-git-info

    local bg ref
    ref="$(print $vcs_info_msg_0_)"
    if [[ -n "${ref}" ]]; then
        if [[ -n "$(git status --porcelain --ignore-submodules)" ]]; then
            bg=yellow
        else
            bg=green
        fi

        if [[ "${ref/.../}" == "${ref}" ]]; then
            ref="${_theme_vcs_branch} ${ref}"
        else
            ref="${_theme_vcs_detached} ${_theme_vcs_cross}"
        fi

        _theme-ender-segment-print $bg black "${ref}"
    fi

    theme run-segment post-git-info
}

_theme-ender-seg-is-root() {
    theme run-segment pre-is-root

    local SU_PROMPT
    case $UID in
        0) SU_PROMPT="${_theme_user_root}" ;;
        *) SU_PROMPT="${_theme_user_other}" ;;
    esac
    _theme-ender-segment-print white black $SU_PROMPT

    theme run-segment post-is-root
}

_theme-ender-seg-elapsed-time() {
    theme run-segment pre-elapsed-time

    local -F epoch=$EPOCHREALTIME
    local -F delta=$(( epoch - _theme_preexec_time ))
    local total_time_s="${delta%.*}"
    local milliseconds="${$(( (".${delta#*.}" * 1000) ))%.*}"

    local color="green"
    local msg=""

    if (( total_time_s >= 3600 )); then
        local -i hours=$((total_time_s / 3600))
        local -i remainder=$((total_time_s % 3600))
        local -i minutes=$((remainder / 60))
        local -i seconds=$((remainder % 60))

        color='red'
        msg="${hours}h${minutes}m${seconds}s"
    elif (( total_time_s >= 60 )); then
        local -i minutes=$((total_time_s / 60))
        local -i seconds=$((total_time_s % 60))

        if (( total_time_s > 600 )); then
            color='red'
        else
            color='yellow'
        fi
        msg="${minutes}m${seconds}s"
    elif (( total_time_s > 5 )); then
        color='blue'
        msg="${total_time_s}s"
    elif (( total_time_s > 1 )); then
        color='cyan'
        msg="${total_time_s}s"
    elif (( total_time_s )); then
        color='green'
        msg="${total_time_s}s${milliseconds}ms"
    else
        color='green'
        msg="${milliseconds}ms"
    fi

    if [[ -n "$msg" ]]; then
        _theme-ender-segment-print $color black "$msg"
    fi

    theme run-segment post-elapsed-time
}

_theme-ender-build-prompt-1() {
    theme run-segment pre-1

    _theme-ender-seg-last-call-status
    _theme-ender-seg-elapsed-time
    # History Size
    _theme-ender-segment-print white black "%h"
    # Hostname
    _theme-ender-segment-print black default "%m"
    _theme-ender-seg-dir

    theme run-segment post-1

    _theme-ender-end-segment
}

_theme-ender-build-prompt2() {
    theme run-segment pre-2

    _theme-ender-seg-time
    _theme-ender-seg-git-info
    _theme-ender-seg-is-root

    theme run-segment post-2

    _theme-ender-end-segment
}

_theme-ender-precmd() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    _theme_ender_current_bg="NONE"

    PROMPT="${(e)$(_theme-ender-build-prompt-1)}
${(e)$(_theme-ender-build-prompt2)} "
}

+vi-git-untracked() {
    if git status --porcelain | grep -q '^?? ' 2> /dev/null; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[unstaged]+='?'
    fi
}

+vi-git-branch() {
    local branch="${hook_com[branch]}"

    local repo_path="$(command git rev-parse --git-dir 2> /dev/null)";

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
        hook_com[branch]+=+='<B>'
    elif [[ -e "${repo_path}/MERGE_AHEAD" ]]; then
        hook_com[branch]+=+='>M<'
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
        hook_com[branch]+=+='>R>'
    fi

    if git rev-parse @{u} &> /dev/null; then
        local -a gitstatus=()

        local -i ahead=$(git rev-list ${branch}@{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
        (( $ahead )) && gitstatus+=( "${_theme_vcs_ahead}${ahead}" )

        local -i behind=$(git rev-list HEAD..${branch}@{u} 2>/dev/null | wc -l | tr -d ' ')
        (( $behind )) && gitstatus+=( "${_theme_vcs_behind}${behind}" )

        if (( ${#gitstatus} )); then
            hook_com[branch]+="${(j:/:)gitstatus}"
        fi
    fi
}

_theme-ender-git-count() {
    local title="$1"
    local count=$2
    local wrapper="${3:-()}"

    if (( count > 1 )); then
        hook_com[misc]+="${wrapper[1]}${title}=${count}${wrapper[2]}"
    elif (( count )); then
        hook_com[misc]+="${wrapper[1]}${title}${wrapper[2]}"
    fi
}

# Show count of stashed changes
+vi-git-stash() {
    local -i stashes=0

    [[ -s ${hook_com[base]}/.git/refs/stash ]] || return 0
    stashes=$(git stash list 2>/dev/null | wc -l)

    _theme-ender-git-count S $stashes '[]'
}

# Show count of commits from the tracking branch that start with '--<text>--'
# and display the count for each <text>
+vi-git-wip() {
    if git rev-parse @{u} &> /dev/null; then
        local base_commit="$(git merge-base @{u} HEAD)" || return 0
        local lines=$(git log --pretty=format:"%s" @{u}..HEAD --regexp-ignore-case --grep='^--[a-zA-Z0-9]*--')

        local -A counts=()

        local line key
        while read -r line; do
            if [[ $line =~ --([A-Z0-9_]+)--* ]]; then
                key=$match[1]

                if [[ -v counts[$key] ]]; then
                    counts[$key]=$(( counts[$key] + 1 ))
                else
                    counts[$key]=1
                fi
            fi
        done <<< "${lines:u}"

        for key in ${(ok)counts}; do
            _theme-ender-git-count "$key" "$counts[$key]"
        done
    fi
}

prompt-ender-setup() {
    emulate -L zsh
    set -uo pipefail
    setopt extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    theme add-segment pre-cmd _theme-ender-precmd

    # Line 1
    theme register-available-segment \
        pre-last-call-status post-last-call-status \
        pre-elapsed-time post-elapsed-time \
        pre-dir post-dir \
        pre-1 post-1

    # Line 2
    theme register-available-segment \
        pre-time post-time \
        pre-git-info post-git-info \
        pre-is-root post-is-root \
        pre-2 post-2

    # Add hook for calling git-info before each command.

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*:*' get-revision true
    zstyle ':vcs_info:git*:*' check-for-changes true

    zstyle ':vcs_info:*' branchformat '%b'
    zstyle ':vcs_info:*' actionformats '%b|%a'
    zstyle ':vcs_info:*' formats '%b %c%u%m'

    zstyle ':vcs_info:*' stagedstr '$_theme_vcs_staged'
    zstyle ':vcs_info:*' unstagedstr '$_theme_vcs_unstaged'
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stash git-wip git-branch

    vcs_info

    # Define prompts.
    PROMPT="${(e)$(_theme-ender-build-prompt-1)}
${(e)$(_theme-ender-build-prompt2)} "
}

prompt-ender-setup "$@"
