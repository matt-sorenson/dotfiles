# This is not a seperate script but a function because it sets environment variables
function aws-signon() {
    local aws_signon_usage="Usage: aws-signon [-f|--force] [-h|--help] [ -p <profile> | --profile <profile> | <profile> ]

Options:
  -f, --force                         Force login even if already signed in
  -h, --help                          Show this help message
  -p <profile>, --profile <profile>   AWS profile to sign into
  <profile>                           AWS profile to sign into

Examples:
  aws-signon -f dev
  aws-signon dev
  aws-signon -p dev"

    local force=false
    local profile

    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                printf '%b\n' "$aws_signon_usage"
                return 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -p|--profile)
                if [[ -n "$profile" ]]; then
                    print-header red "❌ Profile passed in multiple times!"
                    printf '%b\n' "$aws_signon_usage"
                    return 1
                fi

                profile="${2}"
                shift 2
                ;;
            -*)
                print-header red "❌ Unknown option: ${1}"
                printf '%b\n' "$aws_signon_usage"
                return 1
                ;;
            *)
                if [[ -n "$profile" ]]; then
                    print-header red "❌ Profile passed in multiple times!"
                    printf '%b\n' "$aws_signon_usage"
                    return 1
                fi

                profile="${1}"
                shift
                ;;
        esac
    done

    if [[ -z "${profile}" ]]; then
        printf '%b\n' "$aws_signon_usage"
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
