#!/usr/bin/env zsh

# These will change for every repo
local default_repo=
local cmd_str=

autoload -Uz colors && colors

# These variables should be changed for individual use cases and are expected to
# change between different repos.
# Commands like --git-clean are the same between repos so are not exposed here.
local CLEAN_CMD="pnpm clean"
local NUKE_CMD="pnpm clean:nuke"
local INSTALL_CMD="pnpm install"
local BUILD_CMD="pnpm tsc"
local MIGRATIONS_SUBDIR="./"
local DB_UP_CMD=
local MIGRATIONS_CMD=
local UNIT_TESTS_CMD="pnpm unit-test"
local INTEGRATION_TESTS_CMD="pnpm integration-test"

if false; then
    CLEAN_CMD="make clean"
    NUKE_CMD="make nuke"
    INSTALL_CMD="make install"
    BUILD_CMD="make build"
    MIGRATIONS_SUBDIR="migrations"
    DB_UP_CMD=
    MIGRATIONS_CMD=
    UNIT_TESTS_CMD="make unit-test"
    INTEGRATION_TESTS_CMD="make integration-test"
fi

# Override print-header in your .zshenv file (or a script that can be found in your PATH)
# if you don't like the default output format
if ! whence print-header >/dev/null; then
    function print-header(){
        local color="$fg_bold[${1}]"
        local header="${(pl:80::=:)}"
        shift
        local message="${@}"
        echo "$color${header}\n= ${message}\n${header}$reset_color"
    }
fi

function _usage() {
    local default_repo_str=""
    if [[ -z "${default_repo}" ]]; then
        default_repo_str=" (default: ${default_repo})"
    fi

    printf '%s\n' "Usage: ${cmd_str} [options]

Options:
  --git-clean              Clean untracked/ignored files from repo
  -c, --clean              Basic clean of the workspace
  -n, --nuke               clean:nuke, cleanup lots more of the environment
  -i, --install            Install dependencies
  -b, --build              Build
  -m, --migration          Run migrations & Update zapatos schema
  -u, --unit-test          Run unit tests
  --integration-test       Run integration tests
  -t, --test               Run all tests
  -h, --help               Show this help message
  -r <path>, --repo <path> The directory under \$WORKSPACE_ROOT_DIR containing the repo. ${default_repo_str}
  -p <path>, --path <path> The path to the repo. Overrides -r/--repo.

Examples:
  ${cmd_str} -cib                       Run clean and install
  ${cmd_str} --clean --install --build  Run clean and install
  ${cmd_str} -cibt                      Run clean, install, build, and test
  ${cmd_str} -cibt -p /path/to/repo     Run clean, install, build, and test in the specified repo"

    exit "$1"
}

function _error() {
    local help=false
    local parts=()

    # scan every argument
    for arg in "$@"; do
        if [[ $arg == "-h" || $arg == "--help" ]]; then
            help=true
        else
            parts+=("$arg")
        fi
    done

    # join remaining args into one message
    local msg="${parts[*]}"

    print-header red "❌ $msg"

    # if help was requested, show usage
    if $help; then
        _usage 1
    fi

    exit 1
}

local input="$*"

local show_usage=false
# Help check
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        _usage 0
    fi
done

# Show usage help
if [[ -z "$input" ]]; then
    _usage 1
fi

local repo_dir
local repo="${default_repo}"
local -A flags
flags=(
    aws_signon          false
    path                false
    clean               false
    nuke                false
    git_clean           false
    install             false
    build               false
    db_up               false
    migration           false
    test                false
    unit_test           false
    integration_test    false
)

while (( $# )); do
    if [[ "$1" == '--' ]]; then
        shift
        break
    fi

    case "$1" in
    --clean|-c) flags[clean]=true ;;
    --install|-i) flags[install]=true ;;
    --build|-b) flags[build]=true ;;
    --db-up|-d) flags[db_up]=true ;;
    --migration|-m)
        flags[migration]=true;
        flags[aws_signon]=true
        ;;
    --unit-test|-u) flags[unit_test]=true ;;
    --integration-test) flags[integration_test]=true ;;
    --test|-t)
        flags[test]=true
        flags[unit_test]=true;
        flags[integration_test]=true
        ;;
    --git-clean)
        flags[git_clean]=true
        flags[clean]=true
        ;;
    --nuke|-n)
        flags[nuke]=true
        flags[clean]=true
        ;;
    --repo|-r)
        repo="$2"
        shift
        ;;
    --path|-p)
        repo_dir="$2"
        flags[path]=true
        shift
        ;;
    -[!-]*)
        local opts="${1#-}"
        local opt
        for (( i=1; i<=${#opts}; i++ )); do
            opt=${opts:$((i-1)):1}
            case "$opt" in
                c) flags[clean]=true ;;
                n)
                    flags[nuke]=true
                    flags[clean]=true
                    ;;
                i) flags[install]=true ;;
                b) flags[build]=true ;;
                d) flags[db_up]=true ;;
                m) flags[migration]=true; flags[aws_signon]=true ;;
                u) flags[unit_test]=true ;;
                t) flags[test]=true; flags[unit_test]=true; flags[integration_test]=true ;;
                *)
                _error -h "Unknown option: -${opt}"
                ;;
            esac
        done
        ;;
    --*)
        _error -h "Unknown option: $1"
        ;;
    esac
    shift
done

if [[ ${flags[path]} == false ]]; then
    if [[ -z "${WORKSPACE_ROOT_DIR}" ]]; then
        echo "Error: WORKSPACE_ROOT_DIR is not set & -p/--path was not specified."
        if [[ -z "${default_repo}" ]]; then
            echo "       When -r/--repo is not specified, \"${WORKSPACE_ROOT_DIR}/${default_repo}\" is used."
        fi
        _usage 1
    fi
    repo_dir="${WORKSPACE_ROOT_DIR}/${repo}"
fi

if [[ ! -d "${repo_dir}" ]]; then
    _error "The directory '${repo_dir}' does not exist. Please check the path or repo name."
fi

local any_set=false
for v in "${(@v)flags}"; do
    if [[ $v == true ]]; then
        any_set=true
        break
    fi
done

if [[ $any_set == false ]]; then
    _error -h "You must specify at least one option"
fi

# Logic overrides
if [[ ${flags[clean]} == true && ${flags[build]} == true && ${flags[install]} == false ]]; then
    print-header yellow "[override] ⚠️ Adding install: clean + build requires install"
    flags[install]=true
fi

if [[ ${flags[clean]} == true && ${flags[unit_test]} == true ]]; then
    if ! ${flags[install]}; then
        print-header yellow "[override] ⚠️ Adding install: clean + test requires install"
        flags[install]=true
    fi
    if ! ${flags[build]}; then
        print-header yellow "[override] ⚠️ Adding build: clean + test requires build"
        flags[build]=true
    fi
fi

if [[ ${flags[nuke]} == true && ${flags[migration]} == true ]]; then
    if [[ ${flags[db_up]} == false ]]; then
        print-header yellow "[override] ⚠️ Adding db-up: nuke + migration requires db-up"
        flags[db_up]=true
    fi
fi

cd "${repo_dir}" > /dev/null

# Execute steps
if [[ ${flags[git_clean]} == true ]]; then
    print-header green "🧹 git clean"
    git clean -fdx || _error "Git clean failed: git clean -fdx"
fi

if [[ ${flags[nuke]} == true ]]; then
    if [[ -z "${NUKE_CMD}" ]]; then
        _error "NUKE_CMD is not set. Check top of script to configure."
    fi

    print-header green "🧹 Nuke"
    eval ${NUKE_CMD} || {
        _error "Clean nuke failed: ${NUKE_CMD}"
    }
fi

if [[ ${flags[clean]} == true && ${flags[nuke]} == false && ${flags[git_clean]} == false ]]; then
    if [[ -z "${CLEAN_CMD}" ]]; then
        _error "CLEAN_CMD is not set. Check top of script to configure."
    fi

    print-header green "🧹 Clean"
    eval ${CLEAN_CMD} || _error "Clean failed: ${CLEAN_CMD}"
fi

if [[ ${flags[install]} == true ]]; then
    if [[ -z "${INSTALL_CMD}" ]]; then
        _error "INSTALL_CMD is not set. Check top of script to configure."
    fi

    print-header green "Installing dependencies"
    eval ${INSTALL_CMD} || _error "Install failed: ${INSTALL_CMD}"
fi

if [[ ${flags[aws_signon]} == true ]]; then
    aws-signon dev || _error "aws-signon failed"
fi

if [[ ${flags[db_up]} == true ]]; then
    if [[ -z "${DB_UP_CMD}" ]]; then
        _error "DB_UP_CMD is not set. Check top of script to configure."
    fi

    common_store_container_id=$(docker ps -q -f name="common-store-1" -f status=running)

    print-header green "Starting DB Docker container"
    if [[ -z $common_store_container_id ]]; then
        cd "${repo_dir}/${MIGRATIONS_SUBDIR}" > /dev/null
        eval ${DB_UP_CMD} || _error "Starting db failed: ${DB_UP_CMD}"
        cd "${repo_dir}" > /dev/null
    else
        echo "DB Docker container is already running"
    fi
fi

# Migration needs to be run before the build step so that
# the types in 'zapatos/schema 'are up to date
if [[ ${flags[migration]} == true ]]; then
    if [[ -z "${MIGRATIONS_CMD}" ]]; then
        _error "MIGRATIONS_CMD is not set. Check top of script to configure."
    fi

    print-header green "DB Migration"
    cd "${repo_dir}/${MIGRATIONS_SUBDIR}" > /dev/null
    eval ${MIGRATIONS_CMD} || _error "Migration failed: ${MIGRATIONS_CMD}"
    cd "${repo_dir}" > /dev/null
fi

if [[ ${flags[build]} == true ]]; then
    if [[ -z "${BUILD_CMD}" ]]; then
        _error "BUILD_CMD is not set. Check top of script to configure."
    fi

    print-header green "Building Project"
    eval ${BUILD_CMD} || _error "Build failed: ${BUILD_CMD}"
fi

if [[ ${flags[unit_test]} == true ]]; then
    if [[ -z "${UNIT_TESTS_CMD}" ]]; then
        # passing in -t/--test sets the unit_test flag, but shouldn't
        # fail if UNIT_TESTS_CMD is not set. If `test` is not set that
        # means the user specifically requested unit tests and we should
        # treat it as an error.
        if [[ ${flags[test]} == false ]]; then
            _error "UNIT_TESTS_CMD is not set. Check top of script to configure."
        else
            print-header yellow "UNIT_TESTS_CMD missing, skipping."
        fi
    fi

    print-header green "Unit Tests"
    eval ${UNIT_TESTS_CMD} || _error "Tests failed: ${UNIT_TESTS_CMD}"
fi

if [[ ${flags[integration_test]} == true ]]; then
    if [[ -z "${INTEGRATION_TESTS_CMD}" ]]; then
        # passing in -t/--test sets the integration_test flag, but shouldn't
        # fail if INTEGRATION_TESTS_CMD is not set. If `test` is not set that
        # means the user specifically requested integration tests and we should
        # treat it as an error.
        if [[ ${flags[test]} == false ]]; then
            _error "INTEGRATION_TESTS_CMD is not set. Check top of script to configure."
        else
            print-header yellow "INTEGRATION_TESTS_CMD missing, skipping."
        fi
    else
        print-header green "Integration Tests"
        eval ${INTEGRATION_TESTS_CMD} || _error "Tests failed: ${INTEGRATION_TESTS_CMD}"
    fi
fi

print-header green "All steps completed successfully"
exit 0
