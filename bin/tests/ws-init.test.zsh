#! /usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

local project_name="ws-init-test-ws-project-name-1234-._"
local project_dir="${WORKSPACE_ROOT_DIR}/${project_name}"

happy-case() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    ws-init "${project_name}"

    if [[ ! -e "${project_dir}" ]]; then
        print-header -e "${project_dir} not created!"
        return 1
    elif [[ ! -d "${project_dir}" ]]; then
        print-header -e "${project_dir} created but isn't a directory!"
        return 1
    elif [[ ! -d "${project_dir}/.git" ]]; then
        print-header -e "${project_dir} not initialized as a git repo!"
        return 1
    fi

    return 0
}

happy-case-vscode() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    alias code="print-header 'VSCODE: '"

    ws-init "${project_name}" --vscode

    if [[ ! -e "${project_dir}" ]]; then
        print-header -e "${project_dir} not created!"
        return 1
    elif [[ ! -d "${project_dir}" ]]; then
        print-header -e "${project_dir} created but isn't a directory!"
        return 1
    elif [[ ! -d "${project_dir}/.git" ]]; then
        print-header -e "${project_dir} not initialized as a git repo!"
        return 1
    fi

    return 0
}

happy-case-cd() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    local starting_dir="${PWD}"

    ws-init --cd "${project_name}"

    local curr_dir="$(realpath "${PWD}")"
    local expected_dir="$(realpath "${project_dir}")"

    TRAPEXIT() {
        cd "$starting_dir"
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    if [[ ! -e "${expected_dir}" ]]; then
        print-header -e "${project_dir} not created!"
        return 1
    elif [[ ! -d "${expected_dir}" ]]; then
        print-header -e "${project_dir} created but isn't a directory!"
        return 1
    elif [[ ! -d "${expected_dir}/.git" ]]; then
        print-header -e "${project_dir} not initialized as a git repo!"
        return 1
    fi

    if [[ "${curr_dir}" != "${expected_dir}" ]]; then
        if [[ "${curr_dir}" != "$(realpath ${starting_path})" ]]; then
            print-header -e "Changed directory to the wrong directory!"
            return 1
        else
            print-header -e "Didn't change directory!"
            return 1
        fi
    else
        print-header "Changed directory as expected!"
    fi

    return 0
}

happy-case-vscode-error-code-command-succeeds() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    alias code="false"

    ws-init "${project_name}" --vscode

    if [[ ! -e "${project_dir}" ]]; then
        print-header -e "${project_dir} not created!"
        return 1
    elif [[ ! -d "${project_dir}" ]]; then
        print-header -e "${project_dir} created but isn't a directory!"
        return 1
    elif [[ ! -d "${project_dir}/.git" ]]; then
        print-header -e "${project_dir} not initialized as a git repo!"
        return 1
    fi

    return 0
}

happy-case-empty-folder-exists() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    mkdir -p "${project_name}"

    ws-init "${project_name}"

    if [[ ! -e "${project_dir}" ]]; then
        print-header -e "${project_dir} not created!"
        return 1
    elif [[ ! -d "${project_dir}" ]]; then
        print-header -e "${project_dir} created but isn't a directory!"
        return 1
    elif [[ ! -d "${project_dir}/.git" ]]; then
        print-header -e "${project_dir} not initialized as a git repo!"
        return 1
    fi

    return 0
}

error-non-empty-folder-exist() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    if [[ -e "${project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${project_dir}" ]]; then
            rm -rf "${project_dir}"
        fi
    }

    mkdir -p "${project_dir}"
    touch "${project_dir}/fake-file.txt"

    ws-init "${project_name}"

    if [[ -d "${project_dir}/.git" ]]; then
        print-header -e "${project_dir} initialized as a git repo, it shouldn't have!"
        return 1
    fi

    return 0
}

error-invalid-project-name-helper() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    typeset -g invalid_project_name="$1"
    typeset -g invalid_project_dir="${WORKSPACE_ROOT_DIR}/${invalid_project_name}"

    if [[ -e "${invalid_project_dir}" ]]; then
        print-header -e "\${WORKSPACE_ROOT_DIR}/${invalid_project_name} already exists!"
        return 1
    fi

    TRAPEXIT() {
        if [[ -e "${invalid_project_name}" ]]; then
            print-header -e "\${WORKSPACE_ROOT_DIR}/${invalid_project_name} should not have been created!"
            rm -rf "${invalid_project_name}"
        fi

        return 0
    }

    if ws-init "${invalid_project_name}"; then
        print-header "ws-init should have failed!"
    fi

    if [[ -d "${invalid_project_dir}" ]]; then
        print-header -e "${invalid_project_dir} created!"
        return 1
    elif [[ -d "${invalid_project_dir}/.git" ]]; then
        print-header -e "${invalid_project_dir} initialized as a git repo!"
        return 1
    fi

    return 0
}

error-invalid-project-name() {
    error-invalid-project-name-helper "ws/init-test-ws-project-name"
    error-invalid-project-name-helper "@init-test-ws-project-name"
    error-invalid-project-name-helper "!init-test-ws-project-name"
    error-invalid-project-name-helper "init-test-ws-project-name\0"

    unset invalid_project_name invalid_project_dir
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return typeset_to_unset

    local old_code_alias
    if alias code &> /dev/null; then
        unalias code &> /dev/null || true
    fi

    local out=0
    local testee='ws-init'
    local -a test_cases=(
        happy-case
        happy-case-vscode
        happy-case-cd
        happy-case-vscode-error-code-command-succeeds
        happy-case-empty-folder-exists
        error-non-empty-folder-exist
        error-invalid-project-name
    )

    local starting_dir="${PWD}"
    local test_case=happy-case
    for tast_case in "${(k)test_cases[@]}"; do
        run-test "${testee}" "${tast_case}" || (( out += 1 ))
        cd "${starting_dir}"

        if alias code &> /dev/null; then
            unalias code &> /dev/null || true
        fi
    done

    if [[ -v old_code_alias ]]; then
        alias "$old_code_alias"
    fi
    return $out
}

main "$@"
