# No hashbang/compdef, this file should only ever be sourced. It uses the calling
# functions local state as its own.

# Make sure to `source ${DOTFILES}/zsh/zsh-parse-opts-init.zsh`

# TODO
## option_args
### option_args[--foo]=r # required
### option_args[--foo]="array:<array_name>" # Each time it's received append to the named array
### option_args[--foo]="int" # require integer
### option_args[--foo]="file" # require a valid filename
### option_args[--foo]="dir" # require a valid directory
### Required can be combined with types like so
### option_args[--foo]="r:array:<array_name>" # Each time it's received append to the named array, require 1

local -a positional_args=()
local flag no_flag arg arg_list flag_or_no_flag
while (( $# )); do
    case $1 in
    -h|--help)
        print "${_usage}"
        return 0
        ;;
    --?*)
        no_flag="${${1#--no-}//-/_}"
        flag="${${1#--}//-/_}"
        if [[ -v "flags[$no_flag]" ]]; then
            flags[$no_flag]=0
        elif [[ -v "flags[$flag]" ]]; then
            flags[$flag]=1
        elif [[ -v "option_args[$flag]" ]]; then
            if [[ -v "options[$flag]" ]]; then
                print-header -e "Unknown flag: $1"
                print "${_usage}"
                return 1
            elif (( $# < 2 )); then
                print-header -e "Flag '$1' requires a value."
                print "${_usage}"
                return 0
            else
                shift
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
                elif [[ -v "options[$flag]" ]]; then
                    print-header -e "Unknown flag: $1"
                    print "${_usage}"
                    return 1
                elif (( $# < 2 )); then
                    print-header -e "Flag '$1' requires a value."
                    print "${_usage}"
                    return 0
                else
                    shift
                    options[$flag]="$1"
                fi
            else
                print-header -e "Unexpected argument '-$arg'"
                print "${_usage}"
                return 1
            fi
        done
        ;;
    *)
        if  [[ max_position_count == -1 ]] || (( ${#positional_args[@]} < max_position_count )); then
            positional_args+=("$1")
        else
            print-header -e "Too many positional arguments [max: $max_position_count]"
            print "${_usage}"
            return 1
        fi
        ;;
    esac
    shift
done

if [[ -v min_position_count ]] && (( ${#positional_args[@]} < min_position_count )); then
    print-header -e "Too few positional arguments [expected at least $min_position_count]"
    print "${_usage}"
    return 1
fi

set -- "${positional_args[@]}"
unset positional_args flag no_flag arg arg_list flag_or_no_flag