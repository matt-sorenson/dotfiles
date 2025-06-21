#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

root="${DOTFILES}/bin/tests/env"
clean_dir="clean"
nuke_dir="nuke"
install_dir="install"
build_dir="build"
db_up_dir="db_up"
migrations_dir="migrations"
generate_schema_dir="generate_schema"
unit_tests_dir="unit_tests"
integration_tests_dir="integration_tests"

happycase() {
    repoman \
        --calling-name dotfiles \
        --path "$root" \
        --clean-working-dir "${clean_dir}" \
        --nuke-working-dir "${nuke_dir}" \
        --install-working-dir "${install_dir}" \
        --build-working-dir "${build_dir}" \
        --db-up-working-dir "${db_up_dir}" \
        --migrations-working-dir "${migrations_dir}" \
        --generate-schema-working-dir "${generate_schema_dir}" \
        --unit-tests-working-dir "${unit_tests_dir}" \
        --integration-tests-working-dir "${integration_tests_dir}" \
        --clean-cmd 'print "clean $(pwd)"' \
        --nuke-cmd 'print "nuke $(pwd)"' \
        --install-cmd 'print "install $(pwd)"' \
        --build-cmd 'print "build $(pwd)"' \
        --db-up-cmd 'print "db $(pwd)"-up' \
        --migrations-cmd 'print "migration $(pwd)"' \
        --generate-schema-cmd 'print "generate $(pwd)"-schema' \
        --unit-tests-cmd 'print "unit $(pwd)"-tests' \
        --integration-tests-cmd 'print "integration $(pwd)"-tests' \
        -ncibdmguI
}

task-fails() {
    repoman \
        --calling-name dotfiles \
        --path "$root" \
        --clean-working-dir "${clean_dir}" \
        --nuke-working-dir "${nuke_dir}" \
        --install-working-dir "${install_dir}" \
        --build-working-dir "${build_dir}" \
        --db-up-working-dir "${db_up_dir}" \
        --migrations-working-dir "${migrations_dir}" \
        --generate-schema-working-dir "${generate_schema_dir}" \
        --unit-tests-working-dir "${unit_tests_dir}" \
        --integration-tests-working-dir "${integration_tests_dir}" \
        --clean-cmd 'print "clean $(pwd)"' \
        --nuke-cmd 'print "nuke $(pwd)"' \
        --install-cmd 'false' \
        --build-cmd 'print "build $(pwd)"' \
        --db-up-cmd 'print "db $(pwd)"-up' \
        --migrations-cmd 'print "migration $(pwd)"' \
        --generate-schema-cmd 'print "generate $(pwd)"-schema' \
        --unit-tests-cmd 'print "unit $(pwd)"-tests' \
        --integration-tests-cmd 'print "integration $(pwd)"-tests' \
        -ncibdmguI
}

function main() {
    mkdir -p "${root}/${clean_dir}"
    mkdir -p "${root}/${nuke_dir}"
    mkdir -p "${root}/${install_dir}"
    mkdir -p "${root}/${build_dir}"
    mkdir -p "${root}/${db_up_dir}"
    mkdir -p "${root}/${migrations_dir}"
    mkdir -p "${root}/${generate_schema_dir}"
    mkdir -p "${root}/${unit_tests_dir}"
    mkdir -p "${root}/${integration_tests_dir}"

    if [[ ! -v DOTFILES ]] || [[ -z "${DOTFILES}" ]]; then
        print-header -e "DOTFILES must be defined."
        return 1
    fi

    local out=0
    local testee='repoman'
    local -a test_cases=(
        happycase
        task-fails
    )

    for element in "${test_cases[@]}"; do
        run-test "$testee" "$element" || (( out += 1 ))
    done

    rm -rf ${root}

    return $out
}

main "$@"
