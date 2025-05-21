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
