# General coding guidlines
- Prefer 4 space tabs unless required by the file format

## When talking about zsh scripts:
- If `#compdef <script name>` is present, mark file-level vars as local.
- prefer `print` over `echo`
- Use `local _usage` for usage strings near top of functions.
- Assume `$WORKSPACE_ROOT_DIR` and `$DOTFILES` are set.
- Use `print-header -e "<Message>"` for errors, `print-header -w "<Message>"` for warnings. Detailed info can be `print`ed below the header
- use `dot-parse-opts` to parse function/script inputs except in super basic cases
- Helper functions should be declared in the parent functions scope and cleaned up using the `dot-safe-unset-functions` in a TRAPEXIT
  - Example usage `dot-safe-unset-functions <function1> <function2>`

## Using `dot-parse-opts` in zsh scripts/functions:
- Recognize all `option_args` types like `r`, `int`, `float`, `str`, `1`, `file`, `dir`, `mkdir`, `array:<name>`, `overwrite`, `enum:<vals>`.
    - `r` means the argument is required
    - `1` means it takes a value but with no validation
    - `str` means a non-empty string
    - `enum:<vals>` validates that the value received is one of the comma-separated values listed
    - `<type>:array` validates that the value is of `type` before inserting it into the array
    - `array` and `overwrite` are mutually exclusive
    - `file` & `dir` mean that the file must exist
    - `mkdir` checks if the folder exists and if not creates it (and any needed parents)
    - `overwrite` takes the last value provided as the result (useful when a wrapper function provides a default and the caller overrides that)
    - Validation types are checked in order but only one is validated per option
    - option_args may have combined values seperated by `:`, so `r:int` means it's required and an integer
  - `eval "$(dot-parse-opts --dot-parse-opts-init)"` defines all required variables including `short_to_long_flags`, `allow_duplicate_flags`, `flags`, `set_flags`, `short_to_long_opts`, `option_args`, `max_positional_count`, `min_positional_count`, `options`, `allow_extra_args`, `extra_args_are_positional`, `extra_args`, `positional_args`, `dot_parse_opts_errors`, `dot_parse_opts_errors[too-many-positional]`, and. `dot_parse_opts_errors[too-few-positional]`
- `min_positional_count`, `max_positional_count` (-1 for unlimited) is the number of non-flag & option/value parameters will be accepted
- `dot_parse_opts_errors[too-many-positional]`/`dot_parse_opts_errors[too-many-positional]` allow providing clearer error messages. ie "jwt-print only accepts 1 jwt." instead of the generic "Too many positional arguments"
- Short flags: `-f` enables flag, `+f` disables flag, short options with values must be last in combined flags (e.g., `-abc` where `c` takes value is invalid).
- If `flags[help]` is set and `-h` or `--help` is passed, it's treated as a regular flag; otherwise `-h`/`--help` prints `_usage` and returns `-1`.
- `set_flags` tracks which flags have been set; `allow_duplicate_flags` controls duplicate flag behavior for similar usage to option_args's `overwrite`.
- Returns: `-1` for help, `0` for success, any other exit code is an error
- Array options require the target array to be declared before parsing; values are safely appended using `eval "$array_name+=(${(q)1})"`.
- All errors print `_usage` string and use `print-header -e` for error messages.
