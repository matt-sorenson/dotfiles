# You are not expected to run repoman directly but to wrap it, see below
# for a basic example that uses make commands.

# Copy this into your local/zshrc.zsh file, replace all instances of <reponame>
# with the name of the repository you want the function set up for.
# Also fill out/modify any of the additional fields, removing if not needed.

# --migrations-subdir should be the subdirectory of your repo that
# the `--migrations-cmd`/`--db-up-cmd` need to be run from.

# If DOT_DEFAULT_REPO is not set then you must provide -r/--repo or -p/--path
# when calling repoman.
export DOT_DEFAULT_REPO="<reponame>"

# These will change for every repo
function <reponame>() {
    repoman \
        --calling-name <reponame> \
        --clean-cmd "make clean" \
        --nuke-cmd "make nuke" \
        --install-cmd "make install" \
        --build-cmd "make build" \
        --migrations-subdir "" \
        --db-up-cmd "make db-up" \
        --migrations-cmd "make migrations" \
        --unit-tests-cmd "make unit-test" \
        --integration-tests-cmd "make integration-test" \
        --db-container-name "<reponame container>" \
        --verbose-opts "unit-tests" \
        "$@"
}
compdef _repoman <reponame>
