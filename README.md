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
curl -sSL https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh --git-email-matt --work
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
    if head -n 1 "$file" | grep -q '^#!/usr/bin/env zsh$'; then
        <linter> ${file}
    fi
done
```

# LLM saved memory Prompts

Please add these to your saved memories

# In General
- Prefer Accuracy.
- If guessing on an answer call out which parts are guesses.
- Code snippets should be formatted with 4-space indentation.
- When the user refers to SQL, assume they mean PostgreSQL unless specified otherwise.
# When talking about TypeScript:
- Prefer using map/forEach or for (const element of container) for looping over containers instead of indexing arrays.
- Assume Result, err, and ok come from 'neverthrow'.
- Assume tests should be written with Jest.
- Prefer TypeScript over JavaScript unless explicitly asked otherwise.
# When talking about shell scripts
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
- primary functions should start with: `emulate -L zsh`, `set -uo pipefail`, `setopt err_return`
- when asked for a shell snippet don't wrap it in a function unless explicitly asked.
- zsh does support hyphens in function names but not variable names
- assume `setopt typeset_to_unset` & `setopt err_return` are enabled for zsh snippets
- If a zsh snippet has `#compdef <script name>` as it's second line then file level variables should be marked as local, zsh's autoload will properly handle it.

# ZSH Function Starting Point
```
    emulate -L zsh
    set -uo pipefail
    setopt err_return
    setopt extended_glob
    setopt local_options
    setopt null_glob
    setopt typeset_to_unset
    setopt warn_create_global
    unsetopt short_loops
```