#
# A two-line, Powerline-inspired theme that displays contextual information.
#
# This theme requires a patched Powerline font, get them from
# https://github.com/Lokaltog/powerline-fonts.
#
# Authors:
#   Isaac Wolkerstorfer <i@agnoster.net>
#   Jeff Sandberg <ender460@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
# Screenshots:
#   http://i.imgur.com/0XIWX.png
#

# Load dependencies.
pmodload 'helper'

# Define variables.
_prompt_ender_current_bg='NONE'
_prompt_ender_start_time=$SECONDS

function prompt_ender_start_segment() {
  local bg fg
  [[ -n "$1" ]] && bg="%K{$1}" || bg="%k"
  [[ -n "$2" ]] && fg="%F{$2}" || fg="%f"
  if [[ "$_prompt_ender_current_bg" != 'NONE' && "$1" != "$_prompt_ender_current_bg" ]]; then
    print -n " $bg%F{$_prompt_ender_current_bg}$fg "
  else
    print -n "$bg$fg "
  fi
  _prompt_ender_current_bg="$1"
  [[ -n "$3" ]] && print -n "$3"
}

function prompt_ender_end_segment() {
  if [[ -n "$_prompt_ender_current_bg" ]]; then
    print -n " %k%F{$_prompt_ender_current_bg}"
  else
    print -n "%k"
  fi
  print -n "%f"
  _prompt_ender_current_bg=''
}

function prompt_ender_seg_last_call_status() {
  local EXIT_STATUS=$1

  if [[ $EXIT_STATUS == 0 ]]; then
    prompt_ender_start_segment green black '✓'
  else
    prompt_ender_start_segment red black '✘'
  fi
}

function prompt_ender_seg_security() {
  if is-function prompt-security-str; then
    local sec_prompt="$(prompt-security-str)"
    if [ -n "${sec_prompt}" ]; then
      prompt_ender_start_segment red black "${sec_prompt}"
    fi
  fi
}

function prompt_ender_seg_history() {
  prompt_ender_start_segment white black '$[HISTCMD-1]'
}

function prompt_ender_seg_hostname() {
  prompt_ender_start_segment black default '%m%f'
}

function prompt_ender_seg_dir() {
  if [[ $AT_WORK -eq 1 && `pwd` =~ "$WORKSPACE_ROOT_DIR/([^/]*)/([^/]*)/src/([^/]*)(.*)" ]]; then
    prompt_ender_start_segment cyan black "$match[1]"
    prompt_ender_start_segment blue black "$match[2]"
    prompt_ender_start_segment cyan black "$match[3]"
    prompt_ender_start_segment blue black "/${match[4]#?}"
  elif [[ $AT_WORK -eq 1 && `pwd` =~ "$WORKSPACE_ROOT_DIR/([^/]*)/src/([^/]*)(.*)" ]]; then
    prompt_ender_start_segment blue black "$match[1]"
    prompt_ender_start_segment cyan black "$match[2]"
    prompt_ender_start_segment blue black "/${match[3]#?}"
  elif [[ `pwd` =~ "$WORKSPACE_ROOT_DIR/([^/]*)(.*)" ]]; then
    prompt_ender_start_segment cyan black "$match[1]"
    prompt_ender_start_segment blue black "${match[2]#?}"
  else
    prompt_ender_start_segment blue black '%~'
  fi
}

function prompt_ender_seg_SEA_time() {
  prompt_ender_start_segment black default '$(TZ=America/Los_Angeles date +"%H:%M:%S")'
}

function prompt_ender_seg_git_info() {
  if [[ -n "$git_info" ]]; then
    prompt_ender_start_segment green black '${(e)git_info[ref]}${(e)git_info[status]}'
  fi
}

function prompt_ender_seg_is_root() {
  local SU_PROMPT
  case $UID in
    0) SU_PROMPT='#' ;;
    *) SU_PROMPT='λ' ;;
  esac
  prompt_ender_start_segment white black $SU_PROMPT
}

function prompt_ender_build_prompt1() {
  local LAST_CALL_EXIT_STATUS=$?
  _prompt_ender_current_bg='NONE'

  prompt_ender_seg_last_call_status $LAST_CALL_EXIT_STATUS
  prompt_ender_seg_history
  prompt_ender_seg_hostname
  prompt_ender_seg_dir


  prompt_ender_end_segment
}

function prompt_ender_build_prompt2() {
  prompt_ender_seg_SEA_time
  prompt_ender_seg_git_info
  prompt_ender_seg_security
  prompt_ender_seg_is_root

  prompt_ender_end_segment
}

function prompt_ender_print_elapsed_time() {
  local end_time=$(( SECONDS - _prompt_ender_start_time ))
  local hours minutes seconds remainder

  if (( end_time >= 3600 )); then
    hours=$(( end_time / 3600 ))
    remainder=$(( end_time % 3600 ))
    minutes=$(( remainder / 60 ))
    seconds=$(( remainder % 60 ))
    print -P "%B%F{red}>>> elapsed time ${hours}h${minutes}m${seconds}s%b"
  elif (( end_time >= 60 )); then
    minutes=$(( end_time / 60 ))
    seconds=$(( end_time % 60 ))
    print -P "%B%F{yellow}>>> elapsed time ${minutes}m${seconds}s%b"
  elif (( end_time > 10 )); then
    print -P "%B%F{green}>>> elapsed time ${end_time}s%b"
  fi
}

function prompt_ender_precmd() {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS

  # Get Git repository information.
  if (( $+functions[git-info] )); then
    git-info
  fi

  # Calculate and print the elapsed time.
  prompt_ender_print_elapsed_time
}

function prompt_ender_preexec() {
  _prompt_ender_start_time="$SECONDS"
}

function prompt_ender_setup() {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent subst)

  # Load required functions.
  autoload -Uz add-zsh-hook

  # Add hook for calling git-info before each command.
  add-zsh-hook preexec prompt_ender_preexec
  add-zsh-hook precmd prompt_ender_precmd

  # Set editor-info parameters.
  zstyle ':prezto:module:editor:info:completing' format '%B%F{red}...%f%b'
  zstyle ':prezto:module:editor:info:keymap:primary' format '%B%F{blue}❯%f%b'
  zstyle ':prezto:module:editor:info:keymap:primary:overwrite' format '%F{red}♺%f'
  zstyle ':prezto:module:editor:info:keymap:alternate' format '%B%F{red}❮%f%b'

  # Set git-info parameters.
  zstyle ':prezto:module:git:info' verbose 'yes'
  zstyle ':prezto:module:git:info:action' format ' ⁝ %s'
  zstyle ':prezto:module:git:info:added' format ' ✚ %a'
  zstyle ':prezto:module:git:info:ahead' format ' ⬆ %A'
  zstyle ':prezto:module:git:info:behind' format ' ⬇ %B'
  zstyle ':prezto:module:git:info:branch' format '\u00A0%b'
  zstyle ':prezto:module:git:info:commit' format '➦\u00A0%.7c'
  zstyle ':prezto:module:git:info:deleted' format ' ✖'
  zstyle ':prezto:module:git:info:dirty' format ' ⁝'
  zstyle ':prezto:module:git:info:modified' format ' ✱'
  zstyle ':prezto:module:git:info:position' format '%p'
  zstyle ':prezto:module:git:info:renamed' format ' ➙'
  zstyle ':prezto:module:git:info:stashed' format ' S'
  zstyle ':prezto:module:git:info:unmerged' format ' ═'
  zstyle ':prezto:module:git:info:untracked' format ' ?'
  zstyle ':prezto:module:git:info:keys' format \
    'ref' '$(coalesce "%b" "%p" "%c")' \
    'status' '%s%D%A%B%S%a%d%m%r%U%u'

  # Define prompts.
  PROMPT='${(e)$(prompt_ender_build_prompt1)}
${(e)$(prompt_ender_build_prompt2)} '
  RPROMPT=''
  SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

prompt_ender_setup "$@"
