#!/usr/bin/env zsh

# Copy this file into your bin directory and fill in the necessary fields.
#
# Make sure to throw `compdef _repoman mono` in your local zsh completion helper file.

# These will change for every repo
export DOT_DEFAULT_REPO=

repoman \
    --cmd-str "" \
    --clean-cmd "" \
    --nuke-cmd "" \
    --install-cmd "" \
    --build-cmd "" \
    --migrations-subdir "" \
    --db-up-cmd "" \
    --migrations-cmd "" \
    --unit-tests-cmd "" \
    --integration-tests-cmd "" \
    --docker-container-name "" \
    "$@"
