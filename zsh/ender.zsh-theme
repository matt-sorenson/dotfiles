# Heavily modified 'Agnoster' Theme

setopt prompt_subst

# Define variables.
_prompt_ender_current_bg='NONE'
_prompt_ender_start_time=$SECONDS
_prompt_ender_seperator="\ue0b0"
_prompt_ender_plus_minus="\u00b1"
_prompt_ender_plus="\u2795"
_prompt_ender_vcs_branch="\ue0a0"
_prompt_ender_vcs_detached="\u27a6"
_prompt_ender_vcs_cross="\u2718"

_prompt_ender_user_root='#'
_prompt_ender_user_other='λ'

function prompt_ender_bg_color() {
    print -n "%K{$1}"
}

function prompt_ender_fg_color() {
    print -n "%F{$1}"
}

function prompt_ender_start_segment() {
    prompt_ender_bg_color "$1"
    local msg=' '
    if [[ "$_prompt_ender_current_bg" != 'NONE' && "$1" != "$_prompt_ender_current_bg" ]]; then
        prompt_ender_fg_color "$_prompt_ender_current_bg"
        msg="$_prompt_ender_seperator "
    fi

    print -n "$msg"

    prompt_ender_fg_color "$2"
    _prompt_ender_current_bg="$1"
}

function prompt_ender_segment_print() {
    prompt_ender_start_segment "$1" "$2"

    # Remove trailing spaces from the input string to avoid duplicates.
    print -n "${3%%[[:space:]]##} "
}

function prompt_ender_end_segment() {
    if [[ -n "$_prompt_ender_current_bg" ]]; then
        prompt_ender_fg_color $_prompt_ender_current_bg
        print -n "%k"
    fi
    print -n "%k%f"
    _prompt_ender_current_bg='NONE'
}

function prompt_ender_seg_last_call_status() {
    local exit_code=$1
    if (( exit_code )); then
        prompt_ender_segment_print red black '✘'
    else
        prompt_ender_segment_print green black '✓'
    fi
}

function prompt_ender_seg_dir() {
    local working_dir="$(pwd)"
    local msg="%~"

    if [[ "$working_dir" = "${WORKSPACE_ROOT_DIR}"/* ]]; then
        if [[ "${working_dir#${WORKSPACE_ROOT_DIR}}" =~ '/([^/]+)(.*)' ]]; then
            prompt_ender_segment_print yellow black "ws"
            prompt_ender_segment_print cyan black "$match[1]"
            msg="${match[2]#?}"
        fi
    fi

    prompt_ender_segment_print blue black "$msg"
}

function prompt_ender_seg_SEA_time() {
    prompt_ender_segment_print black default "$(TZ=America/Los_Angeles date +"%H:%M:%S")"
}

function prompt_ender_seg_git_info() {
    local bg ref
    ref="$(print $vcs_info_msg_0_)"
    if [[ -n "$ref" ]]; then
        if [[ -n "$(git status --porcelain --ignore-submodules)" ]]; then
            bg=yellow
            _ref="${ref} $_prompt_ender_plus_minus"
        else
            bg=green
            ref="${ref} "
        fi
        if [[ "${ref/.../}" == "$ref" ]]; then
            ref="$_prompt_ender_vcs_branch $ref"
        else
            ref="$_prompt_ender_vcs_detached ${_prompt_ender_vcs_cross/.../}"
        fi

        prompt_ender_segment_print $bg black "$ref"
    fi
}

function prompt_ender_seg_is_root() {
    local SU_PROMPT
    case $UID in
        0) SU_PROMPT="${_prompt_ender_user_root}" ;;
        *) SU_PROMPT="${_prompt_ender_user_other}" ;;
    esac
    prompt_ender_segment_print white black $SU_PROMPT
}

function prompt_ender_build_prompt1() {
    prompt_ender_seg_last_call_status $1
    # History Size
    prompt_ender_segment_print white black "%h"
    # Hostname
    prompt_ender_segment_print black default "%m"
    prompt_ender_seg_dir

    prompt_ender_end_segment
}

function prompt_ender_build_prompt2() {
    prompt_ender_seg_SEA_time
    prompt_ender_seg_git_info
    prompt_ender_seg_is_root

    prompt_ender_end_segment
}

function prompt_ender_print_elapsed_time() {
    local end_time=$(( SECONDS - _prompt_ender_start_time ))

    local color="green"
    local msg=""

    if (( end_time >= 3600 )); then
        local hours=$(( end_time / 3600 ))
        local remainder=$(( end_time % 3600 ))
        local minutes=$(( remainder / 60 ))
        local seconds=$(( remainder % 60 ))

        color='red'
        msg="${hours}h${minutes}m${seconds}s"
    elif (( end_time >= 60 )); then
        local minutes=$(( end_time / 60 ))
        local seconds=$(( end_time % 60 ))
        color='yellow'
        msg="${minutes}m${seconds}s"
    elif (( end_time >= 5 )); then
        color='green'
        msg="${end_time}s"
    fi

    if [[ -n "${msg}" ]]; then
        print -P "%B%F{$color}>>> elapsed time ${msg}%b"
    fi
}

function prompt_ender_precmd() {
    local exit_code=$?
    _prompt_ender_current_bg="NONE"

    setopt LOCAL_OPTIONS
    unsetopt XTRACE KSH_ARRAYS

    vcs_info

    # Calculate and print the elapsed time.
    prompt_ender_print_elapsed_time

    PROMPT="${(e)$(prompt_ender_build_prompt1 $exit_code)}
${(e)$(prompt_ender_build_prompt2)} "
}

function prompt_ender_preexec() {
    _prompt_ender_start_time="$SECONDS"
}

function +vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='?'
    fi
}

function +vi-git-st() {
  local ahead behind remote
  local -a gitstatus

  # Are we on a remote-tracking branch?
  remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
    --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

  if [[ -n ${remote} ]] ; then
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    (( $ahead )) && gitstatus+=( " ${c3}+${ahead}${c2}" )

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l | tr -d ' ')
    (( $behind )) && gitstatus+=( "${c4}-${behind}${c2}" )

    hook_com[branch]="${hook_com[branch]}${(j:/:)gitstatus}"
  fi
}

# Show count of stashed changes
function +vi-git-stash() {
  local -a stashes

  if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
    stashes=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    hook_com[misc]+="(S=${stashes})"
  fi
}

function prompt_ender_setup() {
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    setopt LOCAL_OPTIONS
    unsetopt XTRACE KSH_ARRAYS
    prompt_opts=(cr percent subst)

    # Load required functions.
    autoload -Uz add-zsh-hook

    # Add hook for calling git-info before each command.
    add-zsh-hook preexec prompt_ender_preexec
    add-zsh-hook precmd prompt_ender_precmd

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*:*' get-revision true
    zstyle ':vcs_info:git*:*' check-for-changes true

    zstyle ':vcs_info:*' stagedstr "S"
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' actionformats '%b|%a'
    zstyle ':vcs_info:*' formats '%b %c%u%m'
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stash git-st

    # Define prompts.
    PROMPT="${(e)$(prompt_ender_build_prompt1)}
${(e)$(prompt_ender_build_prompt2)} "
    RPROMPT=""
    SPROMPT="zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? "
}

prompt_ender_setup "$@"
