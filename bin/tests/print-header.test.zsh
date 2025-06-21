#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

# For the tests here since they deal with the colors directly leave the color codes in the expected_results files

function happycase() {
    print-header 'Test'
}

function happycase-indent() {
    print-header --indent 2 'Test'
}

function happycase-icon() {
    print-header --icon 🌖 'Test'
}

function happycase-warning-icon() {
    # This can end up looking odd in a text editor
    # the space after the moon in the output is added for visual alignment
    # in the terminal itself.
    print-header -w --icon 🌖 'Test'
}

function happycase-warning() {
    print-header -w 'Test'
}

function happycase-error() {
    print-header -e 'Test'
}

function flag-after-double-dash() {
    # header should say `--icon 🌖 --indent 2 -e Test` as it's message.
    print-header -- --icon 🌖 --indent 2 -e 'Test'
}

function main() {
    local out=0
    local testee='print-header'
    local -a test_cases=(
        'happycase'
        'happycase-indent'
        'happycase-icon'
        'happycase-warning-icon'
        'happycase-warning'
        'happycase-error'
        'flag-after-double-dash'
    )

    for element in "${(k)test_cases[@]}"; do
        run-test --no-strip-colors "$testee" "$element" || (( out += 1 ))
    done

    return $out
}

main "$@"
