#! /usr/bin/env zsh
#compdef <name>

emulate -L zsh
set -uo pipefail
setopt err_return
setopt typeset_to_unset
setopt warn_create_global
unsetopt short_loops

local _usage="Usage <name>

Options:
"

local -A flags=()
local -A options=()

local flag arg arg_list
while (( $# )); do
    case $1 in
    --help)
        print "${_usage}"
        return 0
        ;;
    -[!-]*)
        arg_list=( "${(@s::)1#-}" )
        while (( ${#arg_list} )); do
            arg=${arg_list[1]}
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
    --no-*)
        flag="${${1#--no-}//-/_}"
        if [[ -v 'flags[$flag]' ]]; then
            flags[$flag]=0
        else
            print-header -e "Unknown flag: $1"
            print "${_usage}"
            return 1
        fi
        ;;
    --*)
        flag="${${1#--}//-/_}"
        if [[ -v 'flags[$flag]' ]]; then
            flags[$flag]=1
        else
            print-header -e "Unknown flag: $1"
            print "${_usage}"
            return 1
        fi
        ;;
    *)
        print-header -e "Unexpected argument '$1'"
        print "${_usage}"
        return 1
        ;;
    esac
    shift
done
unset flag arg arg_list
