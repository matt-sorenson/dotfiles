#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

# For the tests here since they deal with the colors directly leave the color codes in the expected_results files

happycase() {
    print-header 'Test'
}

indent() {
    print-header --indent 2 'Test'
}

icon() {
    print-header --icon 🌖 'Test'
}

warning-icon() {
    # This can end up looking odd in a text editor
    # the space after the moon in the output is added for visual alignment
    # in the terminal itself.
    print-header -w --icon 🌖 'Test'
}

warning() {
    print-header -w 'Test'
}

error() {
    print-header -e 'Test'
}

flag-after-double-dash() {
    # header should say `--icon 🌖 --indent 2 -e Test` as it's message.
    print-header -- --icon 🌖 --indent 2 -e 'Test'
}

main() {
    local out=0
    local testee='print-header'
    local -a test_cases=(
        'happycase'
        'indent'
        'icon'
        'warning-icon'
        'warning'
        'error'
        'flag-after-double-dash'
    )

    for element in "${(k)test_cases[@]}"; do
        run-test --no-sanitize-colors "$testee" "$element" || (( out += 1 ))
    done

    return $out
}

main "$@"
