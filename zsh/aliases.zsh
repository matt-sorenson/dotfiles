alias less='less -XF'
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

function ws()     { pushd "${WORKSPACE_ROOT_DIR}/${1}" }
function wscode() { code  "${WORKSPACE_ROOT_DIR}/${1}" }

# Helper function cause I can never remember the syntax
function is-function() {
    typeset -f "$1" > /dev/null
    return
}

# Recursivly format '.cpp', '.h', '.inl' files in place.
function clang-format-ri() {
    local srcpath="${1}"
    shift
    find "${srcpath}" -type f \( -iname \*.cpp -o -iname \*.h -o -iname \*.inl \) -exec clang-format -i -style=file "$@" {} \;
}

if type jq > /dev/null; then
    function jwt_print () {
        local jwt="${1}";
        if [ -z "${jwt}" ]; then
            if ! type pbpaste > /dev/null; then
                print-header red "ERROR: pbpaste not found. Must pass a JWT as an argument.";
                return 1;
            fi;
            jwt=$(pbpaste);
        fi;
        echo "JWT> ${jwt}";
        echo "Header:";
        echo "${jwt}" | jq -R 'split(".") | .[0] | @base64d | fromjson';
        echo "Payload:";
        echo "${jwt}" | jq -R 'split(".") | .[1] | @base64d | fromjson';
        echo -n "Issued at: ";
        echo "${jwt}" | jq -R 'split(".") | .[1] | @base64d | fromjson | .iat | todate';
        echo -n "Expire at: ";
        echo "${jwt}" | jq -R 'split(".") | .[1] | @base64d | fromjson | .exp | todate';
        echo -n "Sig: ";
        echo "${jwt}" | jq -R 'split(".") | .[2]'
    }
fi

function auto-dot-check-for-update() {
    local hours="${1:-15}"
    local time_limit_in_seconds=$(( 60 * 60 * hours ))
    local current_time=$(date +%s)
    local cuttoff_time=$(($current_time - $time_limit_in_seconds))

    # If the file doesn't exist we treat it as if it was last updated at the epoch
    local last_update=0
    local update_filename="${DOTFILES}/tmp/dotfile-update"
    if [[ -f "${update_filename}" ]]; then
        last_update=$(cat "${update_filename}")
    fi

    if [[ $last_update -lt $cuttoff_time ]]; then
        read -q "RUN_UPDATE?It's been a while, update dotfiles? "
        echo '' # read -q doesn't output a newline
        if [[ "${RUN_UPDATE:l}" == "y" ]]; then
            dot-check-for-update;
        fi
    fi
}
