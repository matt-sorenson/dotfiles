# This is not a seperate script but a function because it sets environment variables
function aws-signon() {
    _aws-signon-usage() {
        echo "Usage: aws-signon [-f | --force] [-h | --help] [ -p <profile> | --profile <profile> | <profile> ]"
        echo "Options:"
        echo "  -f, --force                         Force login even if already signed in"
        echo "  -h, --help                          Show this help message"
        echo "  -p <profile>, --profile <profile>   AWS profile to sign into"
        echo "  <profile>                           AWS profile to sign into"
        echo "Examples:"
        echo "  aws-signon -f dev"
        echo "  aws-signon dev"
        echo "  aws-signon -p dev"
    }

    local force=false
    local profile

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                _aws-signon-usage
                return 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -p|--profile)
                if [[ -n "$profile" ]]; then
                    print-header red "❌ Profile passed in multiple times!"
                    _aws-signon-usage
                    return 1
                fi

                profile="${2}"
                shift 2
                ;;
            -*)
                print-header red "❌ Unknown option: ${1}"
                _aws-signon-usage
                return 1
                ;;
            *)
                if [[ -n "$profile" ]]; then
                    print-header red "❌ Profile passed in multiple times!"
                    _aws-signon-usage
                    return 1
                fi

                profile="${1}"
                shift
                ;;
        esac
    done

    if [[ -z "${profile}" ]]; then
        _aws-signon-usage
        return 1
    fi

    print-header green "🔐 Signing into AWS: ${profile}"

    local EXIT_CODE=0
    if [[ "${force}" == false ]]; then
        aws sts get-caller-identity --profile "${profile}" &> /dev/null
        local EXIT_CODE="$?"
    fi

    export AWS_PROFILE="${profile}"
    if [[ "${EXIT_CODE}" != "0" || "${force}" == true ]]; then
        if [[ "${force}" == false ]]; then
            echo "not signed in, attempting SSO login for '${profile}'..."
        fi
        aws sso login --profile "${profile}"
    else
        echo "already signed in as ${profile}"
    fi
}
