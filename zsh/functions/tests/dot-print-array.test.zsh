#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

happycase() {
    local test_array=('first' 'second' 'third')
    dot-print-array test_array
}

empty-array() {
    local test_array=()
    dot-print-array test_array
}

single-element() {
    local test_array=('only')
    dot-print-array test_array
}

array-with-spaces() {
    local test_array=('first item' 'second item' 'third item')
    dot-print-array test_array
}

array-with-special-chars() {
    local test_array=('item with "quotes"' 'item with $variables' 'item with `backticks`')
    dot-print-array test_array
}

associative-array-error() {
    local -A test_array=('key1' 'value1' 'key2' 'value2')
    dot-print-array test_array
}

undefined-variable-error() {
    dot-print-array undefined_array
}

help-flag() {
    dot-print-array --help
}

short-help-flag() {
    dot-print-array -h
}

too-many-arguments() {
    dot-print-array array1 array2
}

no-arguments() {
    dot-print-array
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global

    local out=0
    local testee='dot-print-array'
    local -a test_cases=(
        happycase
        empty-array
        single-element
        array-with-spaces
        array-with-special-chars
        associative-array-error
        undefined-variable-error
        help-flag
        short-help-flag
        too-many-arguments
        no-arguments
    )

    local test_case
    for test_case in "${(k)test_cases[@]}"; do
        run-test --bin-func "$testee" "$test_case" || (( out += 1 ))
    done

    return $out
}

main "$@"
