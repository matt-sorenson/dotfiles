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
        --db-container-name "<reponame container>" \
        --clean-cmd "echo clean" \
        --nuke-cmd "echo nuke" \
        --install-cmd "echo install" \
        --build-cmd "echo build" \
        --db-up-cmd "echo db-up" \
        --migrations-cmd "echo migrations" \
        --generate-schema-cmd "echo generate-schema" \
        --unit-tests-cmd "echo unit-test" \
        --integration-tests-cmd "echo integration-test" \
        --db-up-working-dir "docker/" \
        --migrations-working-dir "docker/" \
        --generate-schema-working-dir "docker/" \
        --unit-test-verbose \
        --db-up-does-migration \
        "$@"
}

compdef _repoman <reponame>
