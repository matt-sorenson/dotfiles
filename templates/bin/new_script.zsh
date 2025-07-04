#! /usr/bin/env zsh
#compdef <name>

<name>() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob typeset_to_unset warn_create_global 
    unsetopt short_loops

    local _usage="Usage <name>

Options:
  -h, --help    Show this message"

    eval "$(dot-parse-opts --dot-parse-opts-init)"

    # flags[foo]=0
    # short_to_long_flags[f]=foo
    # option_args[input]=1
    # short_to_long_opts[i]=input
    # max_positional_count=2
    # allow_extra_args=1

    dot-parse-opts "$@"

    unset flag_or_no_flag max_positional_count min_positional_count option_args short_to_long_flags short_to_long_opts

    ############################################################################
    ## Your implementation goes here
    ############################################################################
}
