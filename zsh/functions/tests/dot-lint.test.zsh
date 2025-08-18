#! /usr/bin/env zsh

source "${DOTFILES}/zsh/test-harness.zsh"

local test_root="${DOTFILES}/zsh/functions/tests/env/dot-lint"
mkdir -p "$test_root"

# Test file type detection by extension
test-zsh-extension() {
    local test_file="${test_root}/test-zsh-extension.zsh"
    print '#! /usr/bin/env zsh' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-bash-extension() {
    local test_file="${test_root}/test-bash-extension.bash"
    print '#! /usr/bin/env bash' > "$test_file"
    print 'print-header "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-lua-extension() {
    local test_file="${test_root}/test-lua-extension.lua"
    print -- '-- test lua file' > "$test_file"
    print 'print("test")' >> "$test_file"

    dot-lint "$test_file"
    rm -f "$test_file"
}

# Test file type detection by shebang
test-zsh-shebang() {
    local test_file="${test_root}/test-zsh-shebang.zsh"
    print '#! /usr/bin/env zsh' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-bash-shebang() {
    local test_file="${test_root}/test-bash-shebang.bash"
    print '#! /usr/bin/env bash' > "$test_file"
    print 'print-header "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-sh-shebang() {
    local test_file="${test_root}/test-sh-shebang.sh"
    print '#!/bin/sh' > "$test_file"
    print 'print-header "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

# Test hashbang validation
test-invalid-zsh-hashbang() {
    local test_file="${test_root}/test-invalid-zsh-hashbang.zsh"
    print '#!/bin/zsh' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-invalid-bash-hashbang() {
    local test_file="${test_root}/test-invalid-bash-hashbang.bash"
    print '#!/bin/bash' > "$test_file"
    print 'print-header "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-invalid-sh-hashbang() {
    local test_file="${test_root}/test-invalid-sh-hashbang.sh"
    print '#!/usr/bin/env sh' > "$test_file"
    print 'print-header "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

# Test missing hashbang
test-missing-hashbang() {
    local test_file="${test_root}/test-missing-hashbang.zsh"
    print 'print "test"' > "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-zsh-echo-warning() {
    local test_file="${test_root}/test-zsh-echo-warning.zsh"
    print '#!/usr/bin/env zsh' > "$test_file"
    print 'echo "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-help-flag() {
    dot-lint --help
}

test-type-flag() {
    local test_file="${test_root}/test-type-flag.zsh"
    print '#! /usr/bin/env zsh' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint --type zsh "$test_file"
    rm -f "$test_file"
}

test-unsupported-success-flag() {
    local test_file="${test_root}/test-unsupported-success-flag.unknown"
    print 'some unknown content' > "$test_file"
    dot-lint --unsupported-success "$test_file"
    rm -f "$test_file"
}

test-verbose-flag() {
    local test_file="${test_root}/test.zsh"
    print '#! /usr/bin/env zsh' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint --verbose "$test_file"
    rm -f "$test_file"
}

# Test error cases
test-missing-file() {
    dot-lint /nonexistent/file
}

test-unsupported-file-type() {
    local test_file="${test_root}/test.unknown"
    print 'some unknown content' > "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

test-too-many-arguments() {
    dot-lint file1 file2 file3
}

test-invalid-type-option() {
    local test_file="${test_root}/test"
    print 'test content' > "$test_file"
    dot-lint --type invalid "$test_file"
    rm -f "$test_file"
}

test-display-name() {
    local test_file="${test_root}/test.zsh"
    print '#! /usr/bin/env zsh' > "$test_file"
    print 'echo "test"' >> "$test_file"
    dot-lint "$test_file" "custom-name.zsh"
    rm -f "$test_file"
}

test-compdef-file() {
    local test_file="${test_root}/test"
    print '#compdef my-command' > "$test_file"
    print 'print "test"' >> "$test_file"
    dot-lint "$test_file"
    rm -f "$test_file"
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global

    local out=0
    local testee='dot-lint'
    local -a test_cases=(
        test-zsh-extension
        test-bash-extension
        test-lua-extension
        test-zsh-shebang
        test-bash-shebang
        test-sh-shebang
        test-invalid-zsh-hashbang
        test-invalid-bash-hashbang
        test-invalid-sh-hashbang
        test-missing-hashbang
        test-zsh-echo-warning
        test-help-flag
        test-type-flag
        test-unsupported-success-flag
        test-verbose-flag
        test-missing-file
        test-unsupported-file-type
        test-too-many-arguments
        test-invalid-type-option
        test-display-name
        test-compdef-file
    )

    local test_case
    for test_case in "${test_cases[@]}"; do
        run-test --bin-func "$testee" "$test_case" || (( out += 1 ))
    done

    rm -rf "${test_root}"

    return $out
}

main "$@"
