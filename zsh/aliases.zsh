alias less='less -XF'
alias please=sudo
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

ws() {
    if [ ${#} -gt 2 ]; then
        cd "$WORKSPACE_ROOT_DIR/$1/$2/src/$3";
    elif [ ${#} -gt 1 ]; then
        if [ -d "$WORKSPACE_ROOT_DIR/$1/src/$2" ]; then
            cd "$WORKSPACE_ROOT_DIR/$1/src/$2";
        elif [ -d "$WORKSPACE_ROOT_DIR/$1/$2" ]; then
            cd "$WORKSPACE_ROOT_DIR/$1/$2";
        fi
    else
        cd "$WORKSPACE_ROOT_DIR/$1"
    fi
}

is-function() {
    typeset -f "$1" > /dev/null
    return $?
}

clang-format-ri() {
    local srcpath="${1}"
    shift
    find "${srcpath}" -type f \( -iname \*.cpp -o -iname \*.h -o -iname \*.inl \) -exec clang-format -i -style=file "$@" {} \;
}

check-formulas() {
    local -A visited_formulas

    echo "Searching for formulas not depended on by other formulas..."

    for formula in $(brew list); do
        if [[ -z $(brew uses --installed "${formula}") ]] && ! (( ${+visited_formulas[$formula]} )) && [[ $formula != "brew-cask" ]]; then
            read "input?${formula} is not depended on by other formulas. Remove? [Y/n] "
            visited_formulas[$formula]=1
            if [[ "${input}" == "Y" ]]; then
                brew remove "${formula}"
                check_formulas $(brew deps --1 --installed "${formula}")
            fi
        fi
    done
}

print-header(){
    local color="${fg_bold[${1}]}"
    local header="================================================================================"
    shift
    local message="${@}"
    echo "$color${header}\n= ${message}\n${header}$reset_color"
}
