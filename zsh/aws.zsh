# This is not a seperate script but a function because it sets environment variables
function aws-signon() {
    local _usage="Usage: aws-signon [-f|--force] [-h|--help] <profile>

Options:
  -f, --force                         Force login even if already signed in
  -h, --help                          Show this help message
  <profile>                           AWS profile to sign into

Examples:
  aws-signon -f dev
  aws-signon dev
"

    local force=false
    local profile

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                printf '%s' "$_usage"
                return 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -*)
                print-header red "❌ Unknown option: ${1}"
                printf '%s' "$_usage"
                return 1
                ;;
            *)
                if [[ -n "$profile" ]]; then
                    print-header red "❌ Profile passed in multiple times!"
                    printf '%s' "$_usage"
                    return 1
                fi

                profile="${1}"
                shift
                ;;
        esac
    done

    if [[ -z "${profile}" ]]; then
        printf '%s' "$_usage"
        return 1
    fi

    print-header green "🔐 Signing into AWS: ${profile}"

    local exit_code=0
    if [[ "${force}" == false ]]; then
        aws sts get-caller-identity --profile "${profile}" &> /dev/null
        local exit_code="$?"
    fi

    export AWS_PROFILE="${profile}"
    if [[ "${exit_code}" != "0" || "${force}" == true ]]; then
        if [[ "${force}" == false ]]; then
            echo "not signed in, attempting SSO login for '${profile}'..."
        fi
        aws sso login --profile "${profile}"
    else
        echo "already signed in as ${profile}"
    fi
}
