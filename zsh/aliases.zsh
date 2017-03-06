alias less='less -XF'
alias please=sudo
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

ws() {
    if [ ${#} -gt 1 ]; then
        cd "$WORKSPACE_ROOT_DIR/$1/src/$2";
    else
        cd "$WORKSPACE_ROOT_DIR/$1"
    fi
}

is-function() {
  if [ 1 -eq $(type $1 | grep "shell function" | wc -l) ]; then
    return 0
  fi

  return 1
}

clang-format-ri() {
    local srcpath="${1}"
    shift
    find "${srcpath}" -exec clang-format -i -style=file "$@" {} \;
}
