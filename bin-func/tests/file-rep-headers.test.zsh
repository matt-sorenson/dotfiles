#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

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
local lua_test_file="test-file.lua"
local insert_file="insert-content.txt"

################################################################################
## Insert content at end of file if no headers are present.
################################################################################
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

insert-custom-marker-no-existing-headers() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" --marker '}' "$test_file"
    get-file-content "$test_file"
}

finsert-custom-marker-no-existing-headers() {
    create-test-file "$test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --finsert "$insert_file" --marker '}' "$test_file"
    get-file-content "$test_file"
}


################################################################################
## Replace existing headers
################################################################################
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
More content after headers
"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"
}

insert-replace-existing-headers-extra-header-blocks() {
    create-test-file "$test_file" "Content before headers
################################################################################
## Start test-header
################################################################################
Old content here
################################################################################
## End test-header
################################################################################
More content after headers
################################################################################
## Start IGNORE-ME header block
################################################################################
Old content here
################################################################################
## End IGNORE-ME header block
################################################################################"
    file-rep-headers --header "test-header" --insert "New replacement content" "$test_file"
    get-file-content "$test_file"
}

finsert-replace-existing-headers-extra-header-blocks() {
    create-test-file "$test_file" "Content before headers
################################################################################
## Start test-header
################################################################################
Old content here
################################################################################
## End test-header
################################################################################
More content after headers
################################################################################
## Start IGNORE-ME header block
################################################################################
Old content here
################################################################################
## End IGNORE-ME header block
################################################################################"
    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file"
    get-file-content "$test_file"
}

insert-replace-existing-headers-custom-marker() {
    create-test-file "$test_file" "Content before headers
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
}} Start test-header
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
Old content here
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
}} End test-header
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
More content after headers"
    file-rep-headers --header "test-header" --insert "New replacement content" "$test_file" --marker '}'
    get-file-content "$test_file"
}

finsert-replace-existing-headers-custom-marker() {
    create-test-file "$test_file" "Content before headers
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
}} Start test-header
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
Old content here
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
}} End test-header
}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
More content after headers"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$test_file" --marker '}'
    get-file-content "$test_file"
}

################################################################################
## Create new file if no file exists
################################################################################
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
insert-lua-file-no-existing-headers() {
    create-test-file "$lua_test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" "$lua_test_file"
    get-file-content "$lua_test_file"
}

finsert-lua-file-no-existing-headers() {
    create-test-file "$lua_test_file" "Some initial content\nMore content here"
    file-rep-headers --header "test-header" --insert "New content" "$lua_test_file"
    get-file-content "$lua_test_file"
}

insert-lua-file-existing-headers() {
    create-test-file "$lua_test_file" "Content before headers
--------------------------------------------------------------------------------
-- Start test-header
--------------------------------------------------------------------------------
Old content here
--------------------------------------------------------------------------------
-- End test-header
--------------------------------------------------------------------------------
More content after headers"

    file-rep-headers --header "test-header" --insert "New content" "$lua_test_file"
    get-file-content "$lua_test_file"
}

finsert-lua-file-existing-headers() {
    create-test-file "$lua_test_file" "Content before headers
--------------------------------------------------------------------------------
-- Start test-header
--------------------------------------------------------------------------------
Old content here
--------------------------------------------------------------------------------
-- End test-header
--------------------------------------------------------------------------------
More content after headers"

    file-rep-headers --header "test-header" --finsert "$insert_file" "$lua_test_file"
    get-file-content "$lua_test_file"
}

insert-lua-file-create-new-file() {
    file-rep-headers --header "test-header" --insert "New content" "$lua_test_file"
    get-file-content "$lua_test_file"
}

finsert-lua-file-create-new-file() {
    file-rep-headers --header "test-header" --finsert "$insert_file" "$lua_test_file"
    get-file-content "$lua_test_file"
}


main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt typeset_to_unset

    local -i out=0
    local testee='file-rep-headers'
    local -a test_cases=(
        # Insert content at end of file if no headers are present.
        insert-no-existing-headers
        finsert-no-existing-headers
        insert-custom-marker-no-existing-headers
        finsert-custom-marker-no-existing-headers

        # Replace existing block
        insert-replace-existing-headers
        finsert-replace-existing-headers
        insert-replace-existing-headers-extra-header-blocks
        finsert-replace-existing-headers-extra-header-blocks
        insert-replace-existing-headers-custom-marker
        finsert-replace-existing-headers-custom-marker

        # Create new file if no file exists
        insert-create-new-file
        finsert-create-new-file

        # Lua Tests
        insert-lua-file-no-existing-headers
        finsert-lua-file-no-existing-headers
        insert-lua-file-existing-headers
        finsert-lua-file-existing-headers
        insert-lua-file-create-new-file
        finsert-lua-file-create-new-file

        # Error Cases
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

        cleanup-test-files "${test_file}" "${test_file}.bak" "${lua_test_file}" "${lua_test_file}.bak"
    done

    cleanup-test-files "${insert_file}"

    popd

    return $out
}

main "$@"
