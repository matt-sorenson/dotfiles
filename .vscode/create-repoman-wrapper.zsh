#! /usr/bin/env zsh

create-repoman-wrapper() {
    emulate -L zsh
    set -euo pipefail
    setopt typeset_to_unset

    local REPLY

    local _usage="Usage: create-repoman-wrapper [-h|--help] <name>"
    local -a options=()
    local name
    local vscode=0
    local local_zshrc=0
    local template

    while (( $# )); do
        case "$1" in
        -h|--help)
            print $_usage
            return 0
            ;;
        --vscode)
            vscode=1
            ;;
        --zshrc)
            local_zshrc=1
            ;;
        -t|--template)
            if (( $# < 2 )); then
                print-header -e "$1 requires an argument"
                return 1
            elif [[ "$2" != 'pnpm' ]]; then
                print-header -e "Unknown template: $2"
                return 1
            fi

            shift
            template="$1"
            ;;
        *)
            if [[ -v name ]]; then
                print-header -e "Too many parameters. Only one script can be created at a time"
                return 1
            fi

            name="$1"
            ;;
        esac
        shift
    done

    if [[ ! -v name || -z "$name" ]]; then
        print "What should the function be called? "
        if read && [[ -n "$REPLY" ]]; then
            name="$REPLY"
            REPLY=''
        else
            print-header -e "No name provided. Exiting."
            return 1
        fi
    fi

    options+=("--default-repo '${name}'")
    options+=("--calling-name '${name}'")

    print -n "DB Container Name? [If not set will always try db-up even if container is running]: "
    if read && [[ -n "$REPLY" ]]; then
        options+=("--db-container-name '$REPLY'")
    fi
    REPLY=''

    local -a tasks=(
        nuke
        clean
        install
        lint
        build
        db-up
        migrations
        generate-schema
        unit-tests
        integration-tests
    )
    local task

    local -A tasks_pnpm_default_cmds=(
        [nuke]='pnpm clean:nuke'
        [clean]='pnpm clean'
        [install]='pnpm install'
        [lint]='pnpm lint'
        [build]='pnpm build'
        [db-up]='pnpm db:up'
        [migrations]='pnpm db:run-migrations'
        [generate-schema]='pnpm db:generate-schema'
        [unit-tests]='pnpm test'
        [integration-tests]='pnpm test:integration-test'
    )

    local -A task_does_task_options=()

    for ((i = 1; i <= ${#tasks}; i++)); do
        local task1=${tasks[i]}
        task_does_task_options[${task1}]=''
        for ((j = i + 1; j <= ${#tasks}; j++)); do
            local task2=${tasks[j]}
            task_does_task_options[${task1}]+=";${task2}"
        done
    done

    local cmd_set=0
    local req_task
    local implies_task
    local found_task
    for task in "${tasks[@]}"; do
        print-header cyan "Configuring task '$task'"

        print -n "Configure '$task'? [y/N]: "
        if ! read -q; then
            print -n "\nShould '$task' be disabled? [y/N]: "
            if read -q; then
                options+=("--${task}-disabled")
            fi
            print
            continue;
        fi
        print

        if [[ -v template ]]; then
            if [[ "$template" == 'pnpm' && -v "tasks_pnpm_default_cmds[$task]" ]]; then
                print -n "Use default pnpm command for '$task'?  \`${tasks_pnpm_default_cmds[${task}]}\` [Y/n]: "
                if read -q; then
                    options+=("--${task}-cmd '${tasks_pnpm_default_cmds[${task}]}'")
                    cmd_set=1
                fi
                print
            fi
        fi

        if (( ! cmd_set )); then
            print -n "Command for '$task' [leave blank for no command or builtin]: "
            REPLY=''
            if read && [[ -n "$REPLY" ]]; then
                options+=("--${task}-cmd" "$REPLY")
            fi
            REPLY=''
        fi

        # print -n "Should '$task' be verbose-able? [Y/n]: "
        # if read -q; then
        #     print -n "Custom verbose argunent for '$task'? [Y/n]: "
        #     if read -q; then
        #         if [[ "$REPLY" == [Yy] ]]; then
        #             options+=("--${task}-verbose")
        #         fi
        #     else
        #         print -n "Custom verbose argument for '$task': "
        #         if read && [[ -n "$REPLY" ]]; then
        #             options+=("--${task}-verbose-arg $REPLY")
        #         fi
        #     fi
        # fi
        # print

        #print -n "Working dir for '$task' [leave blank for root of repo]: "
        #if read && [[ -n "$REPLY" ]]; then
        #    options+=("--${task}-working-dir" "$REPLY")
        #fi

        # print -n "Does '$task' require other tasks? [y/N]: "
        # REPLY=''
        # if read -q; then
        #     print
        #     for req_task in "${tasks[@]}"; do
        #         # Tasks can only require tasks that come after them in the list
        #         if [[ "$req_task" == "$task" ]]; then
        #             break
        #         fi

        #         print -n "Does '$task' require '$req_task'? [y/N]: "
        #         if read -q; then
        #             options+=("--${task}-requires" "${req_task}")
        #         fi
        #         print
        #     done
        # else
        #     print
        # fi
        # REPLY=''

        # print -n "Does '$task' imply other tasks? [y/N]: "
        # if read -q; then
        #     print
        #     found_task=0
        #     for implies_task in "${tasks[@]}"; do
        #         if (( ! found_task )); then
        #             if [[ "$implies_task" == "$task" ]]; then
        #                 found_task=1
        #             fi
        #             continue
        #         fi

        #         print -n "Does '$task' imply '$implies_task'? [y/N]: "
        #         if read -q; then
        #             options+=("--${task}-does-${implies_task}")
        #         fi
        #         print
        #     done
        # else
        #     print
        # fi
    done

    local filename
    if (( local_zshrc )); then
        filename="${DOTFILES}/local/.zshrc"
        print "Adding function to your local zshrc file: ${filename}"
    elif (( vscode )); then
        filename="$(mktemp)"
    fi


    local formatted=""

    local final="$(printf '%s() {\n    repoman \\\\\\n' "${name}")"

    for opt in "${options[@]}"; do
        final+="$(printf '        %s \\\\\\n' "${opt}")"
    done

    final+='        $@'
    final+="\\n}\\n\\n"
    final+="typeset 'dotfiles_completion_functions[${name}]'='_repoman-wrapper'"

    if (( local_zshrc )); then
        print "${final}" >> "${filename}"
    else
        print "${final}" > "${filename}"
    fi

    if (( vscode )); then
        code "$filename"
    else
        print "${final}"
    fi
}

create-repoman-wrapper "$@"
