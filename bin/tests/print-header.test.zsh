#!/usr/bin/env zsh

# For the tests here since they deal with the colors directly leave the color codes in the expected_results files

function print-header-happycase() {
    local _test="print-header-happycase"
    local result="$(print-header 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function print-header-happycase-indent() {
    local _test="print-header-happycase-indent"
    local result="$(print-header --indent 2 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function print-header-happycase-icon() {
    local _test="print-header-happycase-icon"
    local result="$(print-header --icon 🌖 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function print-header-happycase-warning-icon() {
    local _test="print-header-happycase-warning-icon"
    # This can end up looking odd in a text editor, the space after
    # the ⚠️ is added for terminal printing
    local result="$(print-header -w --icon 🌖 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function print-header-happycase-warning() {
    local _test="print-header-happycase-warning"
    local result="$(print-header -w 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function print-header-happycase-error() {
    local _test="print-header-happycase-error"
    local result="$(print-header -e 'Test')"

    local sanitized="${result//${DOTFILES}/\$\{DOTFILES\}}"
    local expected_filename="${DOTFILES}/bin/tests/expected-results/print-header/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/print-header/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function main() {
    mkdir -p "${DOTFILES}/bin/tests/failed-results/print-header"

    local out=0

    print-header-happycase || (( out+=1 ))
    print-header-happycase-indent || (( out+=1 ))
    print-header-happycase-icon || (( out+=1 ))
    print-header-happycase-warning-icon || (( out+=1 ))
    print-header-happycase-warning || (( out+=1 ))
    print-header-happycase-error || (( out+=1 ))

    if [ -z "$(ls -A "${DOTFILES}/bin/tests/failed-results/print-header")" ]; then
        rmdir "${DOTFILES}/bin/tests/failed-results/print-header"
    fi

    if [ -z "$(ls -A "${DOTFILES}/bin/tests/failed-results/")" ]; then
        rmdir "${DOTFILES}/bin/tests/failed-results/"
    fi

    return $out
}

main "$@"
