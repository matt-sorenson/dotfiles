#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

# Test helper function to create test directories and files
create-test-dir() {
    local dir="$1"
    mkdir -p "$dir"
}

create-test-file() {
    local file="$1"
    local content="${2:-test content}"
    print "$content" > "$file"
}

# Test helper function to clean up test directories
cleanup-test-dirs() {
    while (( $# )); do
        [[ -d "$1" ]] && rm -rf "$1" || true
        shift
    done
}

# Test directories
local test_root="${DOTFILES}/zsh/functions/tests/env/test-rm-empty-tree"
local empty_dir="${test_root}/empty"
local file_dir="${test_root}/with-files"
local nested_empty_dir="${test_root}/nested-empty"
local nested_file_dir="${test_root}/nested-with-files"

################################################################################
## Test cases for rm-empty-tree
################################################################################

# Test: Directory with no files (should be deleted)
empty-directory() {
    create-test-dir "$empty_dir"
    rm-empty-tree "$empty_dir"
    [[ ! -d "$empty_dir" ]] && print "Directory was removed" || print "Directory still exists"
}

# Test: Directory with files (should not be deleted)
directory-with-files() {
    create-test-dir "$file_dir"
    create-test-file "${file_dir}/test.txt"
    rm-empty-tree "$file_dir"
    [[ -d "$file_dir" ]] && print "Directory still exists" || print "Directory was removed"
}

# Test: Directory with subdirectories but no files (should be deleted)
nested-empty-directory() {
    create-test-dir "${nested_empty_dir}/subdir1"
    create-test-dir "${nested_empty_dir}/subdir2/subdir3"
    rm-empty-tree "$nested_empty_dir"
    [[ ! -d "$nested_empty_dir" ]] && print "Directory was removed" || print "Directory still exists"
}

# Test: Directory with subdirectories containing files (should not be deleted)
nested-directory-with-files() {
    create-test-dir "${nested_file_dir}/subdir1"
    create-test-dir "${nested_file_dir}/subdir2/subdir3"
    create-test-file "${nested_file_dir}/subdir2/test.txt"
    rm-empty-tree "$nested_file_dir"
    [[ -d "$nested_file_dir" ]] && print "Directory still exists" || print "Directory was removed"
}

# Test: Non-existent directory (should be no-op)
non-existent-directory() {
    rm-empty-tree "non-existent-dir"
    print "Command completed successfully"
}

# Test: Test mode with empty directory (should return 0)
test-mode-empty() {
    create-test-dir "$empty_dir"
    if rm-empty-tree --test "$empty_dir"; then
        print "Success"
    else
        print "Failure"
    fi
}

# Test: Test mode with non-empty directory (should return 1)
test-mode-with-files() {
    create-test-dir "$file_dir"
    create-test-file "${file_dir}/test.txt"
    if ! rm-empty-tree --test "$file_dir"; then
        print "Success"
    else
        print "Failure"
    fi
}

# Test: Test mode with nested empty directory (should return 0)
test-mode-nested-empty() {
    create-test-dir "${nested_empty_dir}/subdir1"
    create-test-dir "${nested_empty_dir}/subdir2/subdir3"
    if rm-empty-tree --test "$nested_empty_dir"; then
        print "Success"
    else
        print "Failure"
    fi
}

# Test: Test mode with nested directory containing files (should return 1)
test-mode-nested-with-files() {
    create-test-dir "${nested_file_dir}/subdir1"
    create-test-dir "${nested_file_dir}/subdir2/subdir3"
    create-test-file "${nested_file_dir}/subdir2/test.txt"

    if ! rm-empty-tree --test "$nested_file_dir"; then
        print "Success"
    else
        print "Failure"
    fi
}

# Test: Help flag
help-flag() {
    rm-empty-tree --help
}

# Test: Short help flag
short-help-flag() {
    rm-empty-tree -h
}

# Test: Error - too many arguments
too-many-arguments() {
    rm-empty-tree dir1 dir2 2>&1
}

# Test: Error - missing directory
missing-directory() {
    rm-empty-tree 2>&1
}

# Test: Error - invalid flag
invalid-flag() {
    rm-empty-tree --invalid-flag dir1 2>&1
}

main() {
    local out=0
    local testee='rm-empty-tree'
    local -a test_cases=(
        empty-directory
        directory-with-files
        nested-empty-directory
        nested-directory-with-files
        non-existent-directory
        test-mode-empty
        test-mode-with-files
        test-mode-nested-empty
        test-mode-nested-with-files
        help-flag
        short-help-flag
        too-many-arguments
        missing-directory
        invalid-flag
    )

    local element
    for element in "${test_cases[@]}"; do
        # Clean up any existing test directories before each test
        cleanup-test-dirs "$test_root"
        
        run-test --bin-func "$testee" "$element" || (( out += 1 ))
    done

    # Final cleanup
    cleanup-test-dirs "$test_root"

    return $out
}

main "$@"
