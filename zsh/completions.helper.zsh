# This helper file can provide arrays/maps/functions that assist with zsh completion.

typeset -ag _dot_cdk_cmds=(
    deploy
    destroy
    diff
    ls
    metadata
    synth
)

typeset -ag _dot_cdk_profiles=(
    "dev"
    "staging"
    "prod"
)

typeset -ag _repoman_general_opts=(
    '(-r --repo -p --path)'{-r,--repo}'[The directory under $WORKSPACE_ROOT_DIR containing the repo.]:repo:_files -W /${WORKSPACE_ROOT_DIR}/'
    '(-r --repo -p --path)'{-p,--path}'[The path to the repo. Overrides -r/--repo]:path:_directories'
    '(-h --help)'{-h,--help}'[Show help message]'
    '(-v --verbose)'{-v,--verbose}'[Show more verbose output]'
)

typeset -ag _repoman_tasks_args=(
    '--git-clean[Clean untracked/ignored files from repo]'
    '(-c --clean)'{-c,--clean}'[Clean]'
    '(-n --nuke)'{-n,--nuke}'[Clean up development environment, db, docker, etc...]'
    '(-i --install)'{-i,--install}'[Install]'
    '(-b --build)'{-b,--build}'[Build]'
    '(-d --db-up)'{-d,--db-up}'[Run Spin up the DB]'
    '(-m --migration)'{-m,--migration}'[Run migrations]'
    '(-g --generate-schema)'{-g,--generate-schema}'[Generate Schema Files]'
    '(-u --unit-tests)'{-u,--unit-tests}'[Run unit tests]'
    '(-I --integration-tests)'{-I,--integration-tests}'[Run integration tests]'
    '(-t --tests)'{-t,--tests}'[Run all tests]'
)

typeset -ag _dot_test_dirs=(
    "${DOTFILES}/bin/tests"
    "${DOTFILES}/bin-func/tests"
)
