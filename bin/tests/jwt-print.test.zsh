#!/usr/bin/env zsh

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

function jwt-print-happycase() {
    local _test="jwt-print-happycase"
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjQwMDAwfQ.GSMSgnCTkgkE0gufLXxWInLlgH1NYr0wfgSLGmtRk4k"
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function jwt-print-no-header() {
    local _test="jwt-print-no-header"
    local jwt=".eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function jwt-print-no-payload() {
    local _test="jwt-print-no-payload"
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function jwt-print-no-issued-at() {
    local _test="jwt-print-no-issued-at"
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImV4cCI6MTUxNjI0MDAwMH0.XNgaJiftieRy3GWKcIUjH1dAZpNrKNCDMVDxres-mCM"
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function jwt-print-no-expire-at() {
    local _test="jwt-print-no-expire-at"
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function jwt-print-no-sig() {
    local _test="jwt-print-no-sig"
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjQwMDAwfQ."
    local result="$(jwt-print $jwt)"

    sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED ${_test}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

function main() {
    mkdir -p "${DOTFILES}/bin/tests/failed-results/"

    local out=0

    jwt-print-happycase || (( out+=1 ))
    jwt-print-no-header || (( out+=1 ))
    jwt-print-no-payload || (( out+=1 ))
    jwt-print-no-issued-at || (( out+=1 ))
    jwt-print-no-expire-at || (( out+=1 ))
    jwt-print-no-sig || (( out+=1 ))

    if [ -z "$(ls -A "${DOTFILES}/bin/tests/failed-results/")" ]; then
        rmdir "${DOTFILES}/bin/tests/failed-results/"
    fi

    return $out
}

main "$@"
