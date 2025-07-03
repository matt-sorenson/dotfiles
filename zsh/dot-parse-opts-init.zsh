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
## option_args[--foo]=1 # Enabled

## Set max_position_count to -1 if you don't want to bound the input
# local max_position_count=0
# local min_position_count=0

# local allow_extra_args=1

# Do not change the value of these 2 variables, the are for reading after parsing.

## This is where the values of options listed in option_args are stored
# local -A options=()
## This will be any arguments passed in after a lone '--'
# local -a extra_args=()

cat <<'EOF'
local -A short_to_long_flags=()
local -A short_to_long_opts=()
local -A flags=()
local -A option_args=()
local max_position_count=0
local min_position_count=0
local -A options=()
local allow_extra_args=0
local extra_args_are_positional=0
local -a extra_args=()

local dot_parse_opts_too_many_positional="Too many positional arguments"
local dot_parse_opts_too_few_positional="Too few positional arguments"
EOF
