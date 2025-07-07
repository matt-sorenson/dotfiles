# Heavily modified 'Agnoster' Theme

setopt prompt_subst

zmodload zsh/datetime
zmodload zsh/regex

export _prompt_ender_preexec_time=${_prompt_ender_preexec_time:-0}

if (( ! _prompt_ender_preexec_time )); then
    _prompt_ender_preexec_time=$EPOCHREALTIME
fi

_prompt_ender_current_bg='NONE'
_prompt_ender_seperator=''
_prompt_ender_vsc_unstaged='±'
_prompt_ender_vsc_staged='+'
_prompt_ender_vcs_branch=''
_prompt_ender_vcs_detached='➦'
_prompt_ender_vcs_cross='✘'

_prompt_ender_vcs_ahead='↑'
_prompt_ender_vcs_behind='↓'

_prompt_ender_user_root='#'
_prompt_ender_user_other='λ'

function _prompt_ender_bg_color() {
    print -n "%K{$1}"
}

function _prompt_ender_fg_color() {
    print -n "%F{$1}"
}

function _prompt_ender_start_segment() {
    _prompt_ender_bg_color "$1"
    local msg=' '
    if [[ "${_prompt_ender_current_bg}" != 'NONE' && "$1" != "${_prompt_ender_current_bg}" ]]; then
        _prompt_ender_fg_color "${_prompt_ender_current_bg}"
        msg="${_prompt_ender_seperator} "
    fi

    print -n "${msg}"

    _prompt_ender_fg_color "$2"
    _prompt_ender_current_bg="$1"
}

function _prompt_ender_segment_print() {
    _prompt_ender_start_segment "$1" "$2"

    # Remove trailing spaces from the input string to avoid duplicates.
    print -n "${3%%[[:space:]]##} "
}

function _prompt_ender_end_segment() {
    if [[ -n "${_prompt_ender_current_bg}" ]]; then
        _prompt_ender_fg_color ${_prompt_ender_current_bg}
        print -n "%k"
    fi
    print -n "%k%f"
    _prompt_ender_current_bg='NONE'
}

function _prompt_ender_seg_last_call_status() {
    local exit_code=$1
    if (( exit_code )); then
        _prompt_ender_segment_print red black '✘'
    else
        _prompt_ender_segment_print green black '✓'
    fi
}

function _prompt_ender_seg_dir() {
    local working_dir="$(pwd)"
    local msg="%~"

    if [[ "${working_dir}" = "${WORKSPACE_ROOT_DIR}"/* ]]; then
        if [[ "${working_dir#${WORKSPACE_ROOT_DIR}}" =~ '/([^/]+)(.*)' ]]; then
            _prompt_ender_segment_print yellow black "ws"
            _prompt_ender_segment_print cyan black "${match[1]}"
            msg="${match[2]#?}"
        fi
    fi

    _prompt_ender_segment_print blue black "${msg}"
}

function _prompt_ender_seg_SEA_time() {
    _prompt_ender_segment_print black default "$(TZ=America/Los_Angeles date +"%H:%M:%S")"
}

function _prompt_ender_seg_git_info() {
    local bg ref
    ref="$(print $vcs_info_msg_0_)"
    if [[ -n "${ref}" ]]; then
        if [[ -n "$(git status --porcelain --ignore-submodules)" ]]; then
            bg=yellow
        else
            bg=green
        fi

        if [[ "${ref/.../}" == "${ref}" ]]; then
            ref="${_prompt_ender_vcs_branch} ${ref}"
        else
            ref="${_prompt_ender_vcs_detached} ${_prompt_ender_vcs_cross/.../}"
        fi

        _prompt_ender_segment_print $bg black "${ref}"
    fi
}

function _prompt_ender_seg_is_root() {
    local SU_PROMPT
    case $UID in
        0) SU_PROMPT="${_prompt_ender_user_root}" ;;
        *) SU_PROMPT="${_prompt_ender_user_other}" ;;
    esac
    _prompt_ender_segment_print white black $SU_PROMPT
}

function _prompt_ender_seg_elapsed_time() {
    local -F epoch="$EPOCHREALTIME"
    local -F delta=$((epoch - _prompt_ender_preexec_time ))
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
        _prompt_ender_segment_print $color black "$msg"
    fi
}

function _prompt_ender_build_prompt1() {
    _prompt_ender_seg_last_call_status $1
    _prompt_ender_seg_elapsed_time $1
    # History Size
    _prompt_ender_segment_print white black "%h"
    # Hostname
    _prompt_ender_segment_print black default "%m"
    _prompt_ender_seg_dir

    _prompt_ender_end_segment
}

function _prompt_ender_build_prompt2() {
    _prompt_ender_seg_SEA_time
    _prompt_ender_seg_git_info
    _prompt_ender_seg_is_root

    _prompt_ender_end_segment
}

function _prompt_ender_precmd() {
    local exit_code=$?
    _prompt_ender_current_bg="NONE"

    setopt local_options
    unsetopt xtrace ksh_arrays

    vcs_info

    PROMPT="${(e)$(_prompt_ender_build_prompt1 $exit_code)}
${(e)$(_prompt_ender_build_prompt2)} "
}

function _prompt_ender_preexec() {
    _prompt_ender_preexec_time="${EPOCHREALTIME}"
}

function +vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[unstaged]+='?'
    fi
}

function +vi-git-branch() {
    local branch="${hook_com[branch]}"

    local repo_path="$(command git rev-parse --git-dir 2> /dev/null)";

    local append_space=''

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
        (( $ahead )) && gitstatus+=( "${_prompt_ender_vcs_ahead}${ahead}" )

        local -i behind=$(git rev-list HEAD..${branch}@{u} 2>/dev/null | wc -l | tr -d ' ')
        (( $behind )) && gitstatus+=( "${_prompt_ender_vcs_behind}${behind}" )

        if (( ${#gitstatus} )); then
            hook_com[branch]+="${(j:/:)gitstatus}"
        fi
    fi
}

function _prompt_ender_git_count() {
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
function +vi-git-stash() {
    local -i stashes

    [[ -s ${hook_com[base]}/.git/refs/stash ]] || return 0
    stashes=$(git stash list 2>/dev/null | wc -l)

    _prompt_ender_git_count S $stashes '[]'
}

# Show count of commits from the tracking branch that start with '--<text>--'
# and display the count for each <text>
function +vi-git-wip() {
    local base_commit="$(git merge-base @{u} HEAD)" || return 0
    local lines=$(git log --pretty=format:"%s" @{u}..HEAD --regexp-ignore-case --grep='^--[a-zA-Z0-9]*--')

    local -A counts=()

    local line
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

    local key
    for key in ${(ok)counts}; do
        _prompt_ender_git_count "$key" "$counts[$key]"
    done
}

function prompt_ender_setup() {
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    setopt local_options
    unsetopt xtrace ksh_arrays
    prompt_opts=(cr percent subst)

    # Add hook for calling git-info before each command.
    add-zsh-hook preexec _prompt_ender_preexec
    add-zsh-hook precmd _prompt_ender_precmd

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*:*' get-revision true
    zstyle ':vcs_info:git*:*' check-for-changes true

    zstyle ':vcs_info:*' branchformat '%b'
    zstyle ':vcs_info:*' actionformats '%b|%a'
    zstyle ':vcs_info:*' formats '%b %c%u%m'
 
    zstyle ':vcs_info:*' stagedstr '$_prompt_ender_vsc_staged'
    zstyle ':vcs_info:*' unstagedstr '$_prompt_ender_vsc_unstaged'
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stash git-wip git-branch
 
    # Define prompts.
    PROMPT="${(e)$(_prompt_ender_build_prompt1)}
${(e)$(_prompt_ender_build_prompt2)} "
}

prompt_ender_setup "$@"
