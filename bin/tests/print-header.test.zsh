#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

# For the tests here since they deal with the colors directly leave the color codes in the expected_results files

happycase() {
    print-header 'Test'
}

flag-after-double-dash() {
    # header should say `--icon 🌖 --indent 2 -e Test` as it's message.
    print-header -- --icon 🌖 --indent 2 -e 'Test'
}

flag-error() {
    print-header -e 'Test'
}

flag-icon() {
    print-header --icon 🌖 'Test'
}

flag-indent() {
    print-header --indent 2 'Test'
}

flag-no-color() {
    print-header --icon 🌖 --indent 2 -e --no-color 'flag-no-color'
}

flag-warning-icon() {
    # This can end up looking odd in a text editor
    # the space after the moon in the output is added for visual alignment
    # in the terminal itself.
    print-header -w --icon 🌖 'Test'
}

flag-warning() {
    print-header -w 'Test'
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt typeset_to_unset

    local out=0
    local testee='print-header'
    local -a test_cases=(
        happycase
        flag-after-double-dash
        flag-error
        flag-icon
        flag-indent
        flag-no-color
        flag-warning
        flag-warning-icon
    )

    local test_case
    for tast_case in "${(k)test_cases[@]}"; do
        run-test --no-sanitize-colors "$testee" "$tast_case" || (( out += 1 ))
    done

    return $out
}

main "$@"
