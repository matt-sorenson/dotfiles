#!/usr/bin/env zsh

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

run-test() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt typeset_to_unset

    local _unset="Usage run-test <command to test> <test-function-name>"

    local testee_name
    local test_name
    local sanitize_dotfiles_dir=1
    local sanitize_colors=1
    local bootstrap_test=0
    local differ_cmd

    while (( $# )); do
    case $1 in
    --help)
        print "${_usage}"
        return 0
        ;;
    --no-sanitize-dotfiles-dir)
        sanitize_dotfiles_dir=0
        ;;
    --no-strip-colors)
        sanitize_colors=0
        ;;
    --bootstrap) ;& # fallthrough
    --bootstrap-test)
        bootstrap_test=1
        ;;
    --differ-cmd)
        shift
        if (( ! $# )); then
            print-header -e -- "--differ-cmd requires an argument."
        fi
        ;;
    -[!-]*)
        local arg_list=( "${(@s::)1#-}" )
        while (( ${#arg_list} )); do
            local arg=${arg_list[1]}
            # Pop the front of the list
            arg_list=("${arg_list[@]:1}")
            case "${arg}" in
            h)
                print "${_usage}"
                return 0
                ;;
            *)
                print-header -e "Unexpected flag '-$arg' in '$1'"
                print "${_usage}"
                return 1
                ;;
            esac
        done
        ;;
    --*)
        print-header -e "Unexpected flag '$1'"
        print "${_usage}"
        return 1
        ;;
    *)
        if [[ ! -v testee_name ]]; then
            testee_name="$1"
        elif [[ ! -v test_name ]]; then
            test_name="$1"
        else
            print-header -e "Unexpected argument '$1'"
            print "${_usage}"
            return 1
        fi
        ;;
    esac
    shift
    done

    if [[ ! -v testee_name ]]; then
        print-header -e -- "run-test requires the name of the command being tested."
        return 1
    fi
    if [[ ! -v test_name ]]; then
        print-header -e -- "run-test requires the name of the function to call to test the command."
        return 1
    fi

    local result="$($test_name 2>&1)"

    if (( sanitize_dotfiles_dir )); then
        result="${result//${DOTFILES}/\$\{DOTFILES\}}"
        result="${result//${WORKSPACE_ROOT_DIR}\/dotfiles/\$\{DOTFILES\}}"
    fi
    if (( sanitize_colors )); then
        result="$(print -n "$result" | strip-color-codes)"
    fi

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${testee}/${test_name}"

    if (( bootstrap_test )); then
        mkdir -p "${DOTFILES}/bin/tests/expected-results/${testee}"
        print -n "$result" >! "${expected_filename}"
        return 0
    fi

    if [[ ! -f "$expected_filename" ]]; then
        print-header -e "File ${expected_filename}: does not exist"
    elif [[ ! -r "$expected_filename" ]]; then
        print-header -e "File ${expected_filename}: not readable"
    fi

    expected=$(< "${expected_filename}")

    local matches
    if [[ -v differ_cmd ]]; then
        $differ_cmd "${result}" "${expected}"
        matches=$?
    elif [[ "$result" != "${expected}" ]]; then
        matches=0
    else
        matches=1
    fi

    if (( ! matches )); then
        print-header -e "FAILED: ${test_name}"
        mkdir -p "${DOTFILES}/bin/tests/failed-results/${testee_name}"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${testee_name}/${test_name}"
        print -n "${result}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success: ${test_name}"
}
