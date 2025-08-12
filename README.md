# Setup

## Requirements
- zsh
- curl

## Ubuntu Install
Run `apt install -y zsh curl` first

### Install
```sh
curl -sSL https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh
```

## Matt's default Init flags
```sh
curl -sSL https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh --git-dotfiles-matt --work
```

## Other example

```sh
${INSTALL_COMMAND_FROM_ABOVE} \
    --work \
    --git-email 'foo@example.com'
```

# Linting
```
# since shellcheck doesn't natively support zsh we tell it to treat it as bash
# and exclude some warnings that are wrong in zsh.
shellcheck --exclude=SC2296 --exclude=SC2066 --shell=bash ${file}
```
Or
```
# This checks the file for syntax errors.
zsh --no-exec "$file"
```

## All files in bin

```
for file in bin/*(.); do
    if head -n 1 "$file" | grep -q '^#! /usr/bin/env zsh$'; then
        <linter> ${file}
    fi
done
```

# LLM saved memory Prompts

Please add these to your saved memories

## In General
- Code snippets should be formatted with 4-space indentation.
- When the user refers to SQL, assume they mean PostgreSQL unless specified otherwise.
## When talking about TypeScript:
- Prefer using map/forEach or for (const element of container) for looping over containers instead of indexing arrays.
- Assume Result, err, and ok come from 'neverthrow'.
- Assume tests should be written with Jest.
- Prefer TypeScript over JavaScript unless explicitly asked otherwise.
## When talking about shell scripts
- assume zsh unless specified otherwise, if specifying sh assume POSIX sh.
- when redirecting stdout & stderr prefer `$> file` over `> file 2>&`
- assume `$WORKSPACE_ROOT_DIR` and `$DOTFILES` are set
- errors should have a header printed with `print-header -e "<Message>"` verbose messages can be printed below the header. Warnings should use `-w` instead of `-e`
- Headers or important but non-warning/non-error messages can can be called out using `print-header <color> <message>`
- prefer zsh’s builtin `print` over `echo`
- prefer zsh’s `[[]]` & `(())` conditionals over `[]`;
- prefer `0`/`1` over true/false for booleans
- mark variables as `local` whenever possible and call out misses in functions I provide
- for usage strings in functions, use a `local _usage` variable near the top
- primary functions should start with: `emulate -L zsh`, `set -uo pipefail`, `setopt err_return extended_glob typeset_to_unset warn_create_global`
- when asked for a shell snippet don't wrap it in a function unless explicitly asked.
- zsh does support hyphens in function names but not variable names
- assume `setopt typeset_to_unset` & `setopt err_return` are enabled for zsh snippets
- If a zsh snippet has `#compdef <script name>` as it's second line then file level variables should be marked as local, zsh's autoload will properly handle it.

## ZSH dot-parse-opts command

- option_args takes a string with sections split with `:`
    - option_args sections
        - `r`: marked as required and dot-parse-opts will return print an error message and returns an error code if the option is not passed in
        - `int`: Value must be an integer number
        - `float`: Value must be an integer or decimal number
        - `str`: non-empty string
        - `1`: a string (may be empty)
        - `file`: must be a valid file path
        - `dir`: must be a valid directory path
        - `mkdir`: must be a valid directory path, and will create the directory if it does not exist
        - `array:<array_name>`: Appends the value to the array named `<array_name>`. The array must exist.
        - `overwrite`: Allow specifying the same option multiple times, taking the last passed in value.
        - `enum:<value1>,<value2>,...`: Value must be one of the specified values.
- `(min|max)_positional_count`: The minimum or maximum number of positional arguments allowed.
    - positional arguments are stored into positional_args array.
- `allow_extra_args`: If set then any arguments after a lone `--` are stored in the `extra_args` array.
- `extra_args_are_positional`: If set then any arguments after a lone `--` are stored in the `positional_args` array.
- `allow_extra_args=1` && `extra_args_are_positional=1` are mutually exclusive options
- For --help/-h
    - If `flags[help]` is set then dot-parse-opts sets it to 1 and continues, otherwise it prints "${_usage}" and returns -1, which the caller needs to check for

Additionally:

Calling `dot-parse-opts --dot-parse-opts-init` outputs

```
local -A short_to_long_flags=()
local -A short_to_long_opts=()
local -i allow_duplicate_flags=0
local -A flags=()
local -A option_args=()
local -i max_positional_count=0
local -i min_positional_count=0
local -A options=()
local -i allow_extra_args=0
local -i extra_args_are_positional=0
local -a extra_args=()
local -a positional_args=()

local -A dot_parse_opts_errors=(
    [too-many-positional]="Too many positional arguments"
    [too-few-positional]="Too few positional arguments"
)
```

Which means a function calling `eval "$(dot-parse-opts --dot-parse-opts-init)"` has those variables defined locally.

## ZSH Function Starting Point
```
<function-name>() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return extended_glob typeset_to_unset warn_create_global
    unsetopt short_loops

    local _usage="<function-name> [options] <parameters>

Options:
  -h, --help        Show this message"
}
```

# ZSH Profiling
```
    setopt prompt_subst
    setopt local_options
    local PS4='+$(printf "%s %s:%d: " $EPOCHREALTIME ${funcstack[1]:-main} $LINENO)'
    set -x
``
