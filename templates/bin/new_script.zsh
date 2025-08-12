#! /usr/bin/env zsh
#compdef <name>

<name>() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob null_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    local _usage="Usage <name>

Options:
  -h, --help    Show this message"

    eval "$(dot-parse-opts --dot-parse-opts-init)"

    ############################################################################
    ## Your opts config goes here
    ############################################################################
    ## See ${DOTFILES}/bin-func/dot-parse-opts for options.

    # flags[foo]=0
    # short_to_long_flags[f]=foo
    # option_args[input]=str
    # short_to_long_opts[i]=input
    # max_positional_count=2
    # allow_extra_args=1

    local dot_parse_code=0
    dot-parse-opts "$@" || dot_parse_code=$?
    if (( -1 == dot_parse_code )); then # Help was output
        return 0
    elif (( dot_parse_code )); then
        return $dot_parse_code
    fi

    ############################################################################
    ## Your implementation goes here
    ############################################################################
}

<name> "$@"
