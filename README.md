# Setup

In ./local/zshrc.zsh make sure to add `DOT_DEFAULT_REPO='<whatever repo name>'`
if you plan on using repoman. See templates/ for an example of how to use it.

## Ubuntu Install
Run `apt install -y zsh` first

## wget install
```sh
wget -q -O - https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh
```

### curl install
```sh
curl -sSL https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh
```

## Matt's default Init flags
```sh
wget -q -O - https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh --git-email-matt --work
```
```sh
curl -sSL https://raw.githubusercontent.com/matt-sorenson/dotfiles/refs/heads/main/init.zsh | zsh --git-email-matt --work
```

## Other example

```zsh
${INSTALL_COMMAND_FROM_ABOVE} \
    --work \
    --git-email 'foo@example.com'
```

# Shellcheck command
```
# since shellcheck doesn't natively support zsh we tell it to treat it as bash
# and exclude some warnings that are wrong in zsh.
shellcheck --exclude=SC2296 --exclude=SC2066 --shell=bash
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
- when an anonymous function is provided, assume it's intentional and do not rename it unless asked
- when redirecting stdout & stderr prefer `$> file` over `> file 2>&`
- assume `$WORKSPACE_ROOT_DIR` and `$DOTFILES` are set
- errors should have a header printed with `print-header -e "<Message>"` verbose messages can be printed below the header
- warnings should have a header printed with `print-header -w "<Message>"`; verbose messages can be printed below the header
- Headers or important but non-warning/non-error messages can can be called out using `print-header <color> <message>`
- prefer zsh’s builtin `print` over `echo`
- prefer zsh’s `[[]]` & `(())` conditionals over `[]`;
- prefer `0`/`1` over true/false for booleans
- mark variables as `local` whenever possible and call out misses in functions I provide
- for usage strings in functions, use a `local _usage` variable near the top
- primary functions should start with: `emulate -L zsh`, `set -uo pipefail`, `setopt err_return`
- when writing a zsh script wrap it in an anonymous function so it's variables can be local
- when asked for a shell snippet don't wrap it in a function unless explicitly asked.
- When writing a zsh script, the line after the hashbang should be `#compdef <scriptname>`
- zsh does support hyphens in function names but not variable names

# When writing tests for zsh scripts they should be in this format

- Assume print-header exists, use `print-header -e` for errors, 'print-header -w' for warnings
- tests named as `test-case-1` or `test-case-n` in the example below should be named like `command_name-descriptive-name-of-test` using hyphens to seperate words
- cleanup should not include the "failed-results/${_test}" files

```
test-case-1() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

    local _test="<command>-<test-case-descriptor>"

    local result="$(<command and options being tested>)"
    # ${DOTFILES} will be different between machines so replace the paths in the
    # received output with the literal variable name
    local sanitized="$(print -n "${result//${DOTFILES}/\$\{DOTFILES\}}" | strip-color-codes)"

    local expected_filename="${DOTFILES}/bin/tests/expected-results/${_test}"

    expected=$(< "${expected_filename}")

    if [[ "$sanitized" != "${expected}" ]]; then
        print-header -e "FAILED repoman-task-fails"
        local failed_filename="${DOTFILES}/bin/tests/failed-results/${_test}"
        print -n "${sanitized}" >! "${failed_filename}"

        diff "${expected_filename}" "${failed_filename}"

        return 1
    fi

    print "Success ${_test}"
}

main() {
    emulate -L zsh
    set -uo pipefail
    setopt err_return

    <any shared setup>

    local out=0

    test-case-1 || (( out+=1 ))
    <...>
    test-case-n || (( out+=1 ))

    <any shared cleanup>

    return $out
}

main "$@"
```