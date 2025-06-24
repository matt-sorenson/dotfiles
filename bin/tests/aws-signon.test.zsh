#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"
autoload aws-signon

mock_aws_signon_cmd() {
    print -u 2 "mock_aws_signon_cmd: $@"

    return 0
}

mock_aws_logged_on_cmd_signed_on() {
    print -u 2 "mock_aws_logged_on_cmd_signed_on: $@"

    return 0
}

mock_aws_logged_on_cmd_not_signed_on() {
    print -u 2 "mock_aws_logged_on_cmd_not_signed_on: $@"
    return 1
}

profile-signed-on() {
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_signed_on dev
}

profile-not-signed-on() {
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_not_signed_on dev
}

no-profile-AWS_PROFILE-fallback_signed-on() {
    export AWS_PROFILE=dev
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_signed_on
}

no-profile-AWS_PROFILE-fallback_not-signed-on() {
    export AWS_PROFILE=dev
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_not_signed_on
}

no-profile-signed-on() {
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_signed_on
}

no-profile-fallback-not-signed-on() {
    aws-signon --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_not_signed_on
}

force-signed-on() {
    aws-signon --force --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_signed_on dev
}

force-not-signed-on() {
    aws-signon --force --command mock_aws_signon_cmd --logged-in-command mock_aws_logged_on_cmd_not_signed_on dev
}

main() {
    local out=0
    local testee='aws-signon'
    local -a test_cases=(
        profile-signed-on
        profile-not-signed-on
        no-profile-AWS_PROFILE-fallback_signed-on
        no-profile-AWS_PROFILE-fallback_not-signed-on
        no-profile-signed-on
        no-profile-fallback-not-signed-on
        force-signed-on
        force-not-signed-on
    )

    local previous_AWS_PROFILE
    if [[ -v AWS_PROFILE ]]; then
        previous_AWS_PROFILE="$AWS_PROFILE"
        unset AWS_PROFILE
    fi

    for test_fn in "${test_cases[@]}"; do
        if [[ -v AWS_PROFILE ]]; then
            unset AWS_PROFILE
        fi

        run-test "$testee" "$test_fn" || (( out += 1 ))
    done

    if [[ -v previous_AWS_PROFILE ]]; then
        export AWS_PROFILE="$previous_AWS_PROFILE"
    elif [[ -v AWS_PROFILE ]]; then
        unset AWS_PROFILE
    fi

    return $out
}

main "$@"
