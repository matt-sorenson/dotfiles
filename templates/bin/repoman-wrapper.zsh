#!/usr/bin/env zsh

# Copy this file into your bin directory and fill in the necessary fields.
#
# Make sure to throw `compdef _repoman <functionname>` in your local zshrc.

# These will change for every repo
export DOT_DEFAULT_REPO="repo-wrapper"

repoman \
    --calling-name repo-wrapper \
    --clean-cmd "" \
    --nuke-cmd "" \
    --install-cmd "" \
    --build-cmd "" \
    --migrations-subdir "" \
    --db-up-cmd "" \
    --migrations-cmd "" \
    --unit-tests-cmd "" \
    --db-container-name "" \
    "$@"
