#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

root="${DOTFILES}/zsh/functions/tests/env/ws-ls"
test_project="test-project"
test_subdir="subdir"
test_file="test-file.txt"

happycase-basic() {
    ws-ls "$test_project"
}

happycase-with-long-format() {
    ws-ls -l "$test_project"
}

happycase-with-human-readable() {
    ws-ls -h "$test_project"
}

happycase-with-long-and-human-readable() {
    ws-ls -lh "$test_project"
}

happycase-with-one-per-line() {
    ws-ls -1 "$test_project"
}

happycase-with-no-all() {
    ws-ls +A "$test_project"
}

happycase-with-extra-ls-args() {
    ws-ls "$test_project" -- -r
}

happycase-no-project-specified() {
    ws-ls
}

help-case() {
    ws-ls --help
}

describe-case() {
    ws-ls --describe
}

error-nonexistent-project() {
    ws-ls "nonexistent-project"
}

error-too-many-args() {
    ws-ls "$test_project" "extra-arg"
}

main() {
    # Create test environment
    mkdir -p "${root}/${test_project}"
    mkdir -p "${root}/${test_project}/${test_subdir}"
    print "test content" > "${root}/${test_project}/${test_file}"
    print "hidden file" > "${root}/${test_project}/.hidden"

    # Set specific timestamps to match expected results
    # Use a fixed timestamp that should work on both BSD and GNU systems
    # Format: YYYYMMDDhhmm.ss (2025-10-10T13:35:38-0700)
    local fixed_timestamp="202510101335.38"
    touch -t "$fixed_timestamp" "${root}/${test_project}/${test_file}"
    touch -t "$fixed_timestamp" "${root}/${test_project}/.hidden"
    touch -t "$fixed_timestamp" "${root}/${test_project}/${test_subdir}"
    touch -t "$fixed_timestamp" "${root}/${test_project}"

    # Set up environment variables
    export WORKSPACE_ROOT_DIR="$root"
    
    if [[ ! -v DOTFILES ]] || [[ -z "${DOTFILES}" ]]; then
        print-header -e "DOTFILES must be defined."
        return 1
    fi

    local out=0
    local testee='ws-ls'
    local -a test_cases=(
        happycase-basic
        # TODO: These need to be setup to handle running on systems with:
        #   different users/groups
        #   gnu ls/bsd ls differences
        #happycase-with-long-format
        #happycase-with-human-readable
        #happycase-with-long-and-human-readable
        happycase-with-one-per-line
        happycase-with-no-all
        happycase-with-extra-ls-args
        happycase-no-project-specified
        help-case
        describe-case
        error-nonexistent-project
        error-too-many-args
    )

    local element
    for element in "${test_cases[@]}"; do
        run-test --bin-func "$testee" "$element" || (( out += 1 ))
    done

    rm -rf "${root}"

    return $out
}

main "$@"
