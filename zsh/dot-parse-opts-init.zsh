## Map short flags (like `-f`) to long flags (`--foo`)
# `+f` will be treated as `--no-foo` in the above example
# local -A short_to_long_flags=()
## short_to_long_flags[f]=foo

## Map short options (like `-f <filename>`) to long options (`--file <filename>`)
# local -A short_to_long_opts=()
## short_to_long_opts[f]=file

## Boolean flags, can pass in as --flag to enable that flag or --no-flag to disable
# local -A flags=()
## flags[verbose]=0
## flags[quiet]=0

## List of accepted arguments
# local -A option_args=()
## option_args[--foo]=1 # Enabled (any string)
### int, float, file, dir & mkdir are mutually exclusive but not check
### It will only check one so 'int:file' might accept 1 but not /dev/null
### or the other way around. Don't depend on the ordering of checks.
## option_args[--foo]=int # Requires an integer
## option_args[--foo]=float # Requires a float (or int)
## option_args[--foo]=file # Requires a filename
## option_args[--foo]=dir # Requires a directory
## option_args[--foo]=mkdir # Requires a directory, but will create it if it doesn't exist
## option_args[--foo]="array:<array_name>" # Each time it's received append to the named array
                                           # Mutually exclusive with overwrite
## option_args[--foo]="overwrite" # Each time it's received overwrite the value
                                  # Usually that's an error but it's useful for some functions
                                  # that expect to be wrapped by other helper functions
                                  # Mutually exclusive with array.
### Options are compinable so you can do:
## option_args[--foo]="float:array:<array_name>" # Each time it's received append to the named array, require a float (or int)
## option_args[--foo]="overwrite:int" # Each time it's received overwrite the value, require an integer

## Set max_positional_count to -1 if you don't want to bound the input
# local max_positional_count=0
# local min_positional_count=0

# local allow_extra_args=1

# Do not change the value of these 2 variables, the are for reading after parsing.

## This is where the values of options listed in option_args are stored
# local -A options=()
## This will be any arguments passed in after a lone '--'
# local -a extra_args=()

cat <<'EOF'
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

local -A dot_parse_opts_errors=(
    [too-many-positional]="Too many positional arguments"
    [too-few-positional]="Too few positional arguments"
)
EOF
