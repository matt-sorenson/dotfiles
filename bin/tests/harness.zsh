#! /usr/bin/env zsh

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

run-test() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob typeset_to_unset warn_create_global

    local _unset="Usage run-test <command to test> <test-function-name>
  <command-to-test>     the name of the command being tested (just effects logging)
  <test-function-name>  function or command that the test will call and compare the output of
                        to the value in ./expected-values/<command-to-test>/<test-function-name>

On a test failure the received output will be dumped to failed-results/<command-to-test>/<test-function-name>

Options:
  -h, --help    Display this message
  --bootstrap   Don't test against expected results, instead write the expected result

Sanitization Options:
  --no-sanitize-current-dir   Disable sanitize-current-dir
  --no-sanitize-dotfiles-dir  Disable sanitize-dotfiles-dir
  --no-sanitize-colors        Disable sanitize-colors

sanitize-current-dir changes any instances of the string matching the current directory with the literal \${PWD}
sanitize-dotfiles-dir changes any instance matching the path in \$DOTFILES with the literal \${dotfiles}
sanitize-colors strips any terminal color codes from the output. Should only be disabled when you're specifically testing color"

    eval "$(dot-parse-opts --dot-parse-opts-init)"

    flags[sanitize-current-dir]=1
    flags[sanitize-dotfiles-dir]=1
    flags[sanitize-colors]=1
    flags[bootstrap]=0

    min_positional_count=2
    max_positional_count=2

    dot-parse-opts "$@"

    local testee_name="${positional_args[1]}"
    local test_name="${positional_args[2]}"

    if [[ ! -v testee_name ]]; then
        print-header -e -- "run-test requires the name of the command being tested."
        return 1
    fi
    if [[ ! -v test_name ]]; then
        print-header -e -- "run-test requires the name of the function to call to test the command."
        return 1
    fi

    local result="$($test_name 2>&1)"

    if (( flags[sanitize-dotfiles-dir] )); then
        result="${result//${DOTFILES}/\$\{DOTFILES\}}"
        result="${result//${WORKSPACE_ROOT_DIR}\/dotfiles/\$\{DOTFILES\}}"
    fi
    if (( flags[sanitize-current-dir] )); then
        result="${result//${PWD}/\$\{PWD\}}"
    fi
    if (( flags[sanitize-colors] )); then
        result="$(print -n "$result" | strip-color-codes)"
    fi

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${testee}/${test_name}"

    if (( flags[bootstrap] )); then
        mkdir -p "${DOTFILES}/bin/tests/expected-results/${testee}"
        print -n "$result" > "${expected_filename}"
        return 0
    fi

    local matches=0
    if [[ ! -f "$expected_filename" ]]; then
        print-header -e "File ${expected_filename}: does not exist"
    elif [[ ! -r "$expected_filename" ]]; then
        print-header -e "File ${expected_filename}: not readable"
    else
        local expected=$(< "${expected_filename}")
        if [[ "$result" == "${expected}" ]]; then
            matches=1
        fi
    fi

    if (( ! matches )); then
        print-header -e "FAILED: ${test_name}"
        mkdir -p "${DOTFILES}/bin/tests/failed-results/${testee_name}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${testee_name}/${test_name}"
        print -n "${result}" >! "${failed_filename}"

        if [[ -r "$expected_filename" ]]; then
            diff "${expected_filename}" "${failed_filename}"
        fi

        return 1
    fi

    print "Success: ${test_name}"
}
