#! /usr/bin/env zsh

source "${DOTFILES}/bin-func/tests/harness.zsh"

# Test helper function to create test files
create-test-file() {
    local filename="$1"
    local content="$2"
    print -n "$content" > "$filename"
}

# Test helper function to clean up test files
cleanup-test-files() {
    while (( $# )); do
        [[ -f "$1" ]] && rm -f "$1" || true
        shift
    done
}

# Test helper function to get file content
get-file-content() {
    cat "$1" || print "File not found: $1"
}

local test_file="test-file.txt"
local insert_file="insert-content.txt"

insert-no-existing-headers() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content to insert" "$test_file"
    get-file-content "$test_file"
}

finsert-no-existing-headers() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"
}

insert-custom-marker() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" --marker "-" "$test_file"
    get-file-content "$test_file"
}

finsert-custom-marker() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --finsert "$insert_file" --marker "-" "$test_file"
    get-file-content "$test_file"
}

insert-replace-existing-headers() {
    create-test-file "$test_file" "Content before headers
################################################################################
## Start test-header
################################################################################
Old content here
################################################################################
## End test-header
################################################################################
More content after headers"
    file-rep-headers --header "test-header" --insert "New replacement content" "$test_file"
    get-file-content "$test_file"
}

finsert-replace-existing-headers() {
    create-test-file "$test_file" "Content before headers
################################################################################
## Start test-header
################################################################################
Old content here
################################################################################
## End test-header
################################################################################
More content after headers"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"
}

insert-create-new-file() {
    file-rep-headers --header "test-header" --insert "New file content" "$test_file"
    get-file-content "$test_file"
}

finsert-create-new-file() {
    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"
}

################################################################################
## Error Cases Tests
################################################################################
error-missing-header() {
    create-test-file "$test_file" "Some content"
    file-rep-headers --insert "New content" "$test_file"
}

error-missing-insert() {
    create-test-file "$test_file" "Some content"
    file-rep-headers --header "test-header" "$test_file"
}

error-both-insert-options() {
    create-test-file "$test_file" "Some content"
    file-rep-headers --header "test-header" --insert "Text content" --finsert "$insert_file" "$test_file"
}

################################################################################
## Lua Tests
################################################################################
insert-lua-file-no-headers() {
    local test_file="test-file.lua"

    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" "$test_file"
    get-file-content "$test_file"
}

finsert-lua-file-no-headers() {
    local test_file="test-file.lua"

    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" "$test_file"
    get-file-content "$test_file"
}

insert-lua-file-with-headers() {
    local test_file="test-file.lua"

    create-test-file "$test_file" "Content before headers
--------------------------------------------------------------------------------
-- Start test-header
--------------------------------------------------------------------------------
Old content here
--------------------------------------------------------------------------------
-- End test-header
--------------------------------------------------------------------------------
More content after headers"

    file-rep-headers --header "test-header" --insert "New content" "$test_file"
    get-file-content "$test_file"

    cleanup-test-files "$test_file"
}

finsert-lua-file-with-headers() {
    local test_file="test-file.lua"

    create-test-file "$test_file" "Content before headers
--------------------------------------------------------------------------------
-- Start test-header
--------------------------------------------------------------------------------
Old content here
--------------------------------------------------------------------------------
-- End test-header
--------------------------------------------------------------------------------
More content after headers"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"

    cleanup-test-files "$test_file"
}

insert-lua-file-create-new-file() {
    local test_file="test-file.lua"

    file-rep-headers --header "test-header" --insert "New content" "$test_file"
    get-file-content "$test_file"

    cleanup-test-files "$test_file"
}

finsert-lua-file-create-new-file() {
    local test_file="test-file.lua"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"

    cleanup-test-files "$test_file"
}


main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt typeset_to_unset

    local -i out=0
    local testee='file-rep-headers'
    local -a test_cases=(
        insert-no-existing-headers
        insert-custom-marker
        insert-lua-file-no-headers
        insert-lua-file-with-headers
        insert-lua-file-create-new-file
        insert-replace-existing-headers
        insert-create-new-file
        finsert-no-existing-headers
        finsert-custom-marker
        finsert-lua-file-no-headers
        finsert-lua-file-with-headers
        finsert-lua-file-create-new-file
        finsert-replace-existing-headers
        finsert-create-new-file
        error-missing-header
        error-missing-insert
        error-both-insert-options
    )

    pushd "${DOTFILES}/bin-func/tests/"

    create-test-file "$insert_file" "New file content"

    local test_case
    for test_case in "${test_cases[@]}"; do
        cleanup-test-files "$test_file"
        run-test --bin-func "$testee" "$test_case" || (( out += 1 ))
    done

    cleanup-test-files "$test_file" "$insert_file"

    popd

    return $out
}

main "$@"
