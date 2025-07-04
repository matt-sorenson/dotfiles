# No hashbang/compdef, this file should only ever be sourced. It uses the calling
# functions local state as its own.

# Make sure to `source ${DOTFILES}/zsh/zsh-parse-opts-init.zsh`

# TODO
## Scripts
### add-to-path
### git-pushb
### repoman
### ws-clone
### ws-ls

local -a positional_args=()
local -A set_flags=()
local flag arg arg_list flag_or_no_flag arg_val array_name array_type
while (( $# )); do
    case $1 in
    -h|--help)
        print "${_usage}"
        return 0
        ;;
    --?*)
        flag="${${1#--}}"
        if [[ -v 'flags[$flag]' ]]; then
            if (( ! allow_duplicate_flags )) && [[ -v 'set_flags[$flag]' ]]; then
                print-header -e "Flag '$1' has already been set."
                print "${_usage}"
                return 1
            fi
            flags[$flag]=1
            set_flags[$flag]=1
        elif [[ -v 'flags[${flag#no-}]' ]]; then
            if (( ! allow_duplicate_flags )) && [[ -v 'set_flags[${flag#no-}]' ]]; then
                print-header -e "Flag '$1' has already been set."
                print "${_usage}"
                return 1
            fi
            flags[${flag#no-}]=0
            set_flags[${flag#no-}]=1
    elif [[ -v 'option_args[$flag]' ]]; then
            if (( $# < 2 )); then
                print-header -e "Flag '$1' requires a value."
                print "${_usage}"
                return 0
            fi
            shift
            if [[ ":${option_args[$flag]}:" == *:int:* ]]; then
                if [[ ! $1 =~ ^[-+]?[0-9]+$  ]]; then
                    print-header -e "Flag '--$flag' requires an integer value."
                    print "${_usage}"
                    return 1
                fi
            elif [[ ":${option_args[$flag]}:" == *:float:* ]]; then
                if [[ ! $1 =~ ^[-+]?[0-9]*\.?[0-9]+$ ]]; then
                    print-header -e "Flag '--$flag' requires a float value"
                    print "${_usage}"
                    return 1
                fi
            elif [[ ":${option_args[$flag]}:" == *:file:* ]]; then
                if [[ ! -f $1 ]]; then
                    print-header -e "Flag '--$flag' requires a valid file."
                    print "${_usage}"
                    return 1
                fi
            elif [[ ":${option_args[$flag]}:" == *:dir:* ]]; then
                if [[ ! -d $1 ]]; then
                    print-header -e "Flag '--$flag' requires a valid directory."
                    print "${_usage}"
                    return 1
                fi
            elif [[ ":${option_args[$flag]}:" == *:mkdir:* ]]; then
                if [[ ! -d $1 ]]; then
                    mkdir -p "$1" || {
                        print-header -e "Flag '--$flag' requires a valid directory, but failed to create it."
                        print "${_usage}"
                        return 1
                    }
                fi
            fi

            if [[ ":${option_args[$flag]}:" == *:array:* ]]; then
                array_name="${option_args[$flag]#*array:}"
                if array_type="$(typeset -p "$array_name")"; then
                    if [[ "${array_type}" != *' -a '* ]]; then
                        print-header -e "Flag '$1' requires an array to be set, but '${array_name}' is not an array."
                        print "${_usage}"
                        return 1
                    fi
                else
                    print-header -e "Flag '$1' requires an array to be set."
                    print "${_usage}"
                    return 1
                fi

                eval "$array_name+=(${(q)1})"
            else
                if [[ -v 'options[$flag]' ]]; then
                    if [[ ":$options[$flag]:" != ":overwrite:" ]]; then
                        print-header -e "Flag: --$flag' has already been set to '${options[$flag]}'."
                        print "${_usage}"
                        return 1
                    fi
                fi

                options[$flag]="$1"
            fi
        else
            print-header -e "Unknown flag: $1"
            print "${_usage}"
            return 1
        fi
        ;;
    --)
        if (( extra_args_are_positional )); then
            positional_args+=("${@[2,-1]}")
        elif (( allow_extra_args )); then
            extra_args+=("${@[2,-1]}")
        else
            print-header -e "Unexpected argument '--'"
            print "${_usage}"
            return 1
        fi

        set --
        break
        ;;
    +*|-*)
        arg_list=( "${(@s::)1#[-+]}" )
        flag_or_no_flag=1
        if [[ "$1" == '+'* ]]; then
            flag_or_no_flag=0
        fi

        # Process by popping front each time
        while (( ${#arg_list} )); do
            arg=${arg_list[1]}
            # Pop the front of the list
            arg_list=("${arg_list[@]:1}")

            if [[ $arg == 'h' ]]; then
                print "${_usage}"
                return 0
            elif [[ -v "short_to_long_flags[$arg]" ]]; then
                flags[${short_to_long_flags[$arg]}]=${flag_or_no_flag}
            elif [[ -v "short_to_long_opts[$arg]" ]]; then
                flag="${short_to_long_opts[$arg]}"
                if (( ! flag_or_no_flag )); then
                    print-header -e "Unexpected argument '+$arg'"
                    print "${_usage}"
                    return 1
                elif (( $# < 2 )); then
                    print-header -e "Option '$1' requires a value."
                    print "${_usage}"
                    return 0
                elif (( ${#arg_list} )); then
                    print-header -e "Options can only be combined into short flags as the last flag."
                    return 1
                else
                    arg_val="$2"
                    shift 2
                    # Add the full named option to the front of the args
                    # and continue to the next iteration
                    argv=("--$flag" "$arg_val" "$@" )
                fi
            else
                print-header -e "Unexpected argument '-$arg'"
                print "${_usage}"
                return 1
            fi
        done
        ;;
    *)
        if  (( max_positional_count == -1 || ${#positional_args[@]} < max_positional_count )); then
            positional_args+=("$1")
        else
            local error="$(printf "${dot_parse_opts_errors[too-many-positional]}" "[max: $max_positional_count]")"
            print-header -e "${error}"
            unset error
            print "${_usage}"
            return 1
        fi
        ;;
    esac

    if [[ -v arg_val ]]; then
        # not using a sentinal value here because any value we choose is
        # possibly valid so we use `unset`
        unset arg_val
        local arg_val
    else
        shift
    fi
done

if [[ -v min_positional_count ]] && (( ${#positional_args[@]} < min_positional_count )); then
    local error="$(printf "${dot_parse_opts_errors[too-few-positional]}" "[min: $min_positional_count]")"
    print-header -e "${error}"
    print "${_usage}"
    return 1
fi

local key
for key in "${(@k)option_args}"; do
if [[ ":${option_args[$key]}:" == *:r:* ]]; then
    if [[ ! -v "options[$key]" ]]; then
    print-header -e "Option '$key' is required but wasn't provided."
    print "${_usage}"
    return 1
    fi
fi
done

set -- "${positional_args[@]}"

unset positional_args set_flags flag arg arg_list flag_or_no_flag key array_name array_type arg_val