# Override the script to set the AWS_PROFILE environment variable
aws-signon() {
    export AWS_PROFILE

    # If the script is updated to accept any parameters with values we need to
    # update this for loop
    for arg in "$@"; do
        case "$arg" in
            -*|--*)
                # Ignore any other optoins, we don't care in this function
                ;;
            *)
                AWS_PROFILE="${arg}"
                break
                ;;
        esac
    done

    # Use `command` so that it skips over this function and runs the actual script in $PATH
    command aws-signon "$@"
}
