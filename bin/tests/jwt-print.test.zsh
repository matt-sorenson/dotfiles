#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

happycase() {
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjQwMDAwfQ.GSMSgnCTkgkE0gufLXxWInLlgH1NYr0wfgSLGmtRk4k"
    jwt-print "$jwt"
}

no-header() {
    local jwt=".eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    jwt-print "$jwt"
}

no-payload() {
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    jwt-print "$jwt"
}

no-issued-at() {
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImV4cCI6MTUxNjI0MDAwMH0.XNgaJiftieRy3GWKcIUjH1dAZpNrKNCDMVDxres-mCM"
    jwt-print "$jwt"
}

no-expire-at() {
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.KMUFsIDTnFmyG3nMiGM6H9FNFUROf3wh7SmqJp-QV30"
    jwt-print "$jwt"
}

no-sig() {
    local jwt="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjQwMDAwfQ."
    jwt-print "$jwt"
}

main() {
    local out=0
    local testee='jwt-print'
    local -a test_cases=(
        happycase
        no-header
        no-payload
        no-issued-at
        no-expire-at
        no-sig
    )

    for element in "${test_cases[@]}"; do
        run-test "$testee" "$element" || (( out += 1 ))
    done

    return $out
}

main "$@"
