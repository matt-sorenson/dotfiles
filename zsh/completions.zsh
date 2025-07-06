_aws-signon() {
    _arguments -s \
        '(-f --force)'{-f,--force}'[force login even if already signed in]' \
        '(-h --help)'{-h,--help}'[show help message]' \
        '1:profile:(${_dot_cdk_profiles})'
}
compdef _aws-signon aws-signon

_dot-check-for-update() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-d +d --dotfiles --no-dotfiles){-d,--dotfiles}[Update dotfiles repo]' \
        '(-p +p --plugins --no-plugins){-p,--plugins}[Update dependencies]' \
        '(-l +l --local --no-local)'{-l,--local}'[Update local]' \
        '(-b +b --brew --no-brew)'{-b,--brew}'[Update brew]' \
        '(-e +e --doom --no-doom)'{-d,--doom}'[Update doomemacs]' \
        '(-d +d --dotfiles --no-dotfiles){+d,--no-dotfiles}[Do not update dotfiles repo]' \
        '(-p +p --plugins --no-plugins)--no-plugins[Do not update dependencies]' \
        '(-l +l --local --no-local)'{+l,--no-local}'[Do not update local]' \
        '(-b +b --brew --no-brew)'{+b,--no-brew}'[Do not update brew]' \
        '(-e +e --doom --no-doom)'{+e,--no-doom}'[Do not update doomemacs]' \
        '--auto[Only run if enough time has passed]' \
        '--no-replace-shell[Do not replace the current shell with a new one]'
}
compdef _dot-check-for-update dot-check-for-update

_dot-check-for-update-git() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-i --indent)'{-i,--indent}'[Indent the header 'n' spaces.]'
}
compdef _dot-check-for-update-git dot-check-for-update-git

_git-alias() {
    _arguments -s '(-h --help)'{-h,--help}'[Show help]'
}
zstyle ':completion:*:*:git:*' user-commands alias:'Show all the git aliases configured'

_git-dag() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-a --all)'{-a,--all}'[Show all branches]' \
        '*:branch name:->branch' \
        && return 0

    case $state in
        branch)
            local branchs=( ${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads)"} )
            compadd -a ms_branchs
            ;;
    esac
}
zstyle ':completion:*:*:git:*' user-commands dag:'Show the git history as a directed acyclic graph'

_git-pprune() {
    _arguments -C -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-f --force)'{-f,--force}'[Delete any branches identified without asking]' \
        '(-e --exclude)'{-e,--exclude}'[Exclude a branch by name]:exclude:__git_heads' \
        '(-p --exclude-pattern)'{-p,--exclude-pattern}'[Exclude branch names with a zsh glob]:exclude_pattern: '
}

_git-popb() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-q --quiet)'{-q,--quiet}'[Less output]' \
        "--no-init[Don't initialize the stack file if it's empty]"
}

_git-pushb() {
    # While it's not a perfect 1:1 as calling git-checkout it does for pretty much
    # all my use cases so reuse the _git-checkout completion function
    _git-checkout
}

_git-stack() {
    _arguments -s \
        '(-c, --clean)'{-c,--clean}'[Clear the branch stack]' \
        '(-h --help)'{-h,--help}'[Show help]'
}

_git-stack-init() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-q --quiet)'{-q,--quiet}'[Less output]' \
        "--no-clear[Don't clear the stack file first]"
}

zstyle ':completion:*:*:git:*' user-commands \
    'dag:Displays the git commit history in a directed acyclic graph format' \
    'pprune:Pull and prune local branches that have been deleted on the remote' \
    'popb:pop the last branch off your git stack and check it out' \
    'pushb:push the current branch to the top of the stack and checkout the new branch' \
    'stack:show your current git branch stack' \
    'stack-init:Use the reflog to initialize a stack file for git-stack' \
    'pushf:Push the current branch to the default remote, use --force-with-lease to try to force push' \
    'gcf:Run a heavy duty cleanup of the local repo. Will clear the reflog, prune all branches, and delete all untracked files and directories.' \
    'authors:List all the authors of the current git repository' \
    'olog:Show the git commit history in a one-line format' \
    'amend:Amend the staged files to the last commit' \
    'tracking:Show the current branch and its upstream tracking branch' \
    'wipe:Add all the files to a commit with message "WIPE SAVEPOINT" and then go back to HEAD' \
    'alias:List all of the git aliases configured'

_print-header() {
    _arguments -s \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-i --indent)'{-i,--indent}'[Indent the header by 'n' spaces]' \
        '(-w --warn)'{-w,--warn}'[Format the header as a warning]' \
        '(-e --error)'{-e,--error}'[Format the header as an error]' \
        '--icon[Emoji to prepend to the message]:icon:(🧪 🧹 ✅ ❌ 💾 📁 📅 📦 🔐 ✂️ ⭐ 🛠️ ⚠️ ⚡ 📧)'
}
compdef _print-header print-header

_repoman() {
    local -a _repoman_tasks=(
        'git-clean'
        'nuke'
        'clean'
        'install'
        'lint'
        'build'
        'aws-signon'
        'db-up'
        'migrations'
        'generate_schema'
        'unit-tests'
        'integration_tests'
    )

    local -a _repoman_args=()

    local task
    for task in "${_repoman_tasks[@]}"; do
        _repoman_args+=("--${task}-working-dir[Directory to run the '${task}-working-cmd' from]:${task}-working:_directories")
        _repoman_args+=("(--${task}-verbose --${task}--verbose-arg)--${task}-verbose[Alias for '--${task}-verbose-arg --verbose']")
        _repoman_args+=("(--${task}-verbose --${task}--verbose-arg)--${task}-verbose-arg[Argument to add to generate-"${task}-verbose-cmd" if -v/--verbose is passed in]:${task}-verbose-arg: ")
        _repoman_args+=("--${task}-cmd[Command to run for the '${task}' task]:${task}-cmd:_command_names")
    done
    unset task _repoman_tasks

    _repoman_args+=(
        '--git-clean-does-clean[Implies that if --git-clean is passed in then "clean" should be skipped]'
        '--nuke-does-clean[Implies that if --nuke is passed in then "clean" should be skipped]'
        '--db-up-does-migrations[Implies that if --db-up is passed in then "migrations" should be skipped]'
        '--db-up-does-generate-schema[Implies that if --db-up is passed in then "generate-schema" should be skipped]'
        '--migrations-does-generate-schema[Implies that if --migrations is passed in then "generate-schema" should be skipped]'
    )

    _arguments -s -S -C \
        "${_repoman_general_opts[@]}" \
        "${_repoman_tasks_args[@]}" \
        "${_repoman_args[@]}"
}
compdef _repoman repoman

_repoman-wrapper() {
    _arguments -s -S -C \
        "${_repoman_general_opts[@]}" \
        "${_repoman_tasks_args[@]}"
}
# this will be used in '${DOTFILES}/local/zsh/*' files for functions, so none defined here.

_ws-clone() {
    _arguments -s -C \
        '(-h --help)'{-h,--help}'[Show help]' \
        '(-s --soft-link --no-link)'{-s,--soft-link}'[Directory to create a soft link to the repo]:soft_link_dir:_directories' \
        '(-r --root)'{-r,--root}'[Directory to clone into a subfolder of]:root_dir:_directories' \
        '(-s --soft-link --no-link)--no-link[Disable automatic softlink creation]' \
        '--code[Open the cloned repo in VS Code]'
}
compdef _ws-clone ws-clone

_ws() {
    local -a subcommands=()

    local -a commands=(ls code)

    local cmd key
    for cmd in ${(f)"$(whence -m 'ws-*')"}; do
        commands+=("${cmd#ws-}")
    done

    print start > test.txt

    if (( ${#words} > 1 )); then
        if (( ${commands[(I)$words[2]]} )); then
            local fn="_ws-${words[2]}"
            if command -v "${fn}" > /dev/null; then
                words=("${fn#_}" "${words[@]:2}")
                CURRENT=$(( CURRENT - 1 ))

                $fn
                return
            fi
        fi
    fi

    local -a _descriptions=(
        "ls:list the contents of \${WORKSPACE_ROOT_DIR} or subdirectory"
        "code:Open a vs code window in the given project's directory"
    )
    for cmd in ${(f)"$(whence -m 'ws-*')"}; do
        _descriptions+=("${cmd#ws-}:$($cmd --describe)")
    done

    printf '%s\n' "${_descriptions[@]}" >> test.txt

    _files -W /${WORKSPACE_ROOT_DIR}/
    _describe -t commands "ws subcommands" _descriptions
}
compdef _ws ws
