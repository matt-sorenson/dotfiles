#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

happycase() {
    local -A test_map=(
        key1 value1
        key2 value2
        key3 value3
    )
    dot-print-map test_map
}

empty-map() {
    local -A empty_map=()
    dot-print-map empty_map
}

special-characters() {
    local -A special_map=(
        'key with spaces' 'value with spaces'
        'key-with-dashes' 'value-with-dashes'
        'key_with_underscores' 'value_with_underscores'
        'key:with:colons' 'value:with:colons'
    )
    dot-print-map special_map
}

numeric-keys() {
    local -A numeric_map=(
        1 'first value'
        2 'second value'
        10 'tenth value'
    )
    dot-print-map numeric_map
}

error-undefined-variable() {
    dot-print-map nonexistent_map
}

error-not-associative-array() {
    local -a regular_array=(item1 item2 item3)
    dot-print-map regular_array
}

error-scalar-variable() {
    local scalar_var="just a string"
    dot-print-map scalar_var
}

help-flag() {
    dot-print-map --help
}

short-help-flag() {
    dot-print-map -h
}

error-no-arguments() {
    dot-print-map
}

error-too-many-arguments() {
    local -A test_map=(key value)
    dot-print-map test_map extra_arg
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global

    local out=0
    local testee='dot-print-map'
    local -a test_cases=(
        happycase
        empty-map
        special-characters
        numeric-keys
        error-undefined-variable
        error-not-associative-array
        error-scalar-variable
        help-flag
        short-help-flag
        error-no-arguments
        error-too-many-arguments
    )

    local test_case
    for test_case in "${(k)test_cases[@]}"; do
        run-test --bin-func "$testee" "$test_case" || (( out += 1 ))
    done

    return $out
}

main "$@"
