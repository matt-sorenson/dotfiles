#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/run-test.zsh"

# For the tests here since they deal with the colors directly leave the color codes in the expected_results files

function print-header-happycase() {
    print-header 'Test'
}

function print-header-happycase-indent() {
    print-header --indent 2 'Test'
}

function print-header-happycase-icon() {
    print-header --icon 🌖 'Test'
}

function print-header-happycase-warning-icon() {
    # This can end up looking odd in a text editor
    # the space after the moon in the output is added for visual alignment
    # in the terminal itself.
    print-header -w --icon 🌖 'Test'
}

function print-header-happycase-warning() {
    print-header -w 'Test'
}

function print-header-happycase-error() {
    print-header -e 'Test'
}

function print-header-flag-after-double-dash() {
    # header should say `--icon 🌖 --indent 2 -e Test` as it's message.
    print-header -- --icon 🌖 --indent 2 -e 'Test'
}

function main() {
    local out=0
    local testee='print-header'
    local -a test_cases=(
        'print-header-happycase'
        'print-header-happycase-indent'
        'print-header-happycase-icon'
        'print-header-happycase-warning-icon'
        'print-header-happycase-warning'
        'print-header-happycase-error'
        'print-header-flag-after-double-dash'
    )

    for element in "${(k)test_cases[@]}"; do
        run-test --no-strip-colors "$testee" "$element" || (( out += 1 ))
    done

    return $out
}

main "$@"
