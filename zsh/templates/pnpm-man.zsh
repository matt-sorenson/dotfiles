#!/usr/bin/env zsh

set -euo pipefail
autoload -Uz colors && colors

DB_CONTAINER_ID=

# These will change for every repo
DEFAULT_REPO=
CMD_STR=

# These variables should be changed for individual use cases and are expected to
# change between different repos.
# Commands like --git-clean are the same between repos so are not exposed here.
CLEAN_CMD=
NUKE_CMD=
INSTALL_CMD=
BUILD_CMD=
MIGRATIONS_SUBDIR=
DB_UP_CMD=
MIGRATIONS_CMD=
UNIT_TESTS_CMD=
INTEGRATION_TESTS_CMD=

if 0; then
    CLEAN_CMD="make clean"
    NUKE_CMD="make nuke"
    INSTALL_CMD="make install"
    BUILD_CMD="make build"
    MIGRATIONS_SUBDIR="migrations"
    DB_UP_CMD=''
    MIGRATIONS_CMD=''
    UNIT_TESTS_CMD="make unit-test"
    INTEGRATION_TESTS_CMD="make integration-test"
fi

function _usage() {
    local default_repo_str=""
    if [[ -z "${DEFAULT_REPO}" ]]; then
        default_repo_str=" (default: ${DEFAULT_REPO})"
    fi

    printf '%s\n' "Usage: ${CMD_STR} [options]

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
  -r <repo>, --repo <repo> The directory under \$WORKSPACE_ROOT_DIR containing the repo. ${default_repo_str}
  -p <path>, --path <path> The path to the repo. Overrides -r/--repo.

Examples:
  ${CMD_STR} -cib                       Run clean and install
  ${CMD_STR} --clean --install --build  Run clean and install
  ${CMD_STR} -cibt                      Run clean, install, build, and test
  ${CMD_STR} -cibt -p /path/to/repo     Run clean, install, build, and test in the specified repo"

    exit "${1:-0}"
}

_error() {
    local help=0
    local parts=()

    while (( $# )); doo
        case "${1}" in
            -h|--help)
                help=1
                ;;
            *)
                parts+=("$arg")
                ;;
        esac
        shift
    done

    print-header red "❌ ${parts[*]}"

    # if help was requested, show usage
    if (( help )); then
        _usage 1
    fi

    exit 1
}

local repo_dir
local repo="${DEFAULT_REPO}"
local -A flags
flags=(
    aws_signon          0
    path                0
    clean               0
    nuke                0
    git_clean           0
    install             0
    build               0
    db_up               0
    migration           0
    test                0
    unit_test           0
    integration_test    0
)

while (( $# )); do
    case "$1" in
        -h|--help)
            _usage 0
            ;;
        --)
            shift
            break
            ;;
        --clean|-c) flags[clean]=1 ;;
        --install|-i) flags[install]=1 ;;
        --build|-b) flags[build]=1 ;;
        --db-up|-d) flags[db_up]=1 ;;
        --migration|-m)
            flags[migration]=1;
            flags[aws_signon]=1
            ;;
        --unit-test|-u) flags[unit_test]=1 ;;
        --integration-test) flags[integration_test]=1 ;;
        --test|-t)
            flags[test]=1
            flags[unit_test]=1;
            flags[integration_test]=1
            ;;
        --git-clean)
            flags[git_clean]=1
            flags[clean]=1
            ;;
        --nuke|-n)
            flags[nuke]=1
            flags[clean]=1
            ;;
        --repo|-r)
                if (( $# < 2 )); then
                    _error -h "missing argument for $1"
                fi

            repo="$2"
            shift
            ;;
        --path|-p)
                if (( $# < 2 )); then
                    _error -h "missing argument for $1"
                fi

            repo_dir="$2"
            flags[path]=1
            shift
            ;;
        -[!-]*)
            local opts="${1#-}" # Remove leading dash
            local opt
            for opt in ${(s::)opts}; do
                case "$opt" in
                    c) flags[clean]=1 ;;
                    n)
                        flags[nuke]=1
                        flags[clean]=1
                        ;;
                    i) flags[install]=1 ;;
                    b) flags[build]=1 ;;
                    d) flags[db_up]=1 ;;
                    m)
                        flags[migration]=1
                        flags[aws_signon]=1
                        ;;
                    u) flags[unit_test]=1 ;;
                    t)
                        flags[test]=1
                        flags[unit_test]=1
                        flags[integration_test]=1
                        ;;
                    *)
                        _error -h "Unknown option: -${opt}"
                        ;;
                esac
            done
            ;;
        --*)
            _error -h "Unknown option: $1"
            ;;
        *)
            _error -h "Unexpected argument: $1"
    esac
    shift
done

if (( ! flags[path] )); then
    if [[ -z "${WORKSPACE_ROOT_DIR}" ]]; then
        echo "Error: WORKSPACE_ROOT_DIR is not set & -p/--path was not specified."
        if [[ -z "${DEFAULT_REPO}" ]]; then
            echo "       When -r/--repo is not specified, \"${WORKSPACE_ROOT_DIR}/${DEFAULT_REPO}\" is used."
        fi
        _usage 1
    fi
    repo_dir="${WORKSPACE_ROOT_DIR}/${repo}"
fi

if [[ ! -d "${repo_dir}" ]]; then
    _error "The directory '${repo_dir}' does not exist. Please check the path or repo name."
fi

local any_set=0
for v in "${(@v)flags}"; do
    if (( v )); then
        any_set=1
        break
    fi
done

if (( ! any_set )); then
    _error -h "You must specify at least one option"
fi

# Logic overrides
if (( flags[clean] && flags[build] && ! flags[install] )); then
    print-header yellow "[override] ⚠️ Adding install: clean + build requires install"
    flags[install]=1
fi

if (( flags[clean] && flags[unit_test] )); then
    if (( ! flags[install] )); then
        print-header yellow "[override] ⚠️ Adding install: clean + test requires install"
        flags[install]=1
    fi
    if (( ! flags[build] )); then
        print-header yellow "[override] ⚠️ Adding build: clean + test requires build"
        flags[build]=1
    fi
fi

if (( flags[nuke] && ! flags[db_up] && flags[migration] )); then
    print-header yellow "[override] ⚠️ Adding db-up: nuke + migration requires db-up"
    flags[db_up]=1
fi

cd "${repo_dir}" > /dev/null

# Execute steps
if (( flags[git_clean] )); then
    print-header green "🧹 git clean"
    git clean -fdx || _error "Git clean failed: git clean -fdx"
fi

if (( flags[nuke] )); then
    if [[ -z "${NUKE_CMD}" ]]; then
        _error "NUKE_CMD is not set. Check top of script to configure."
    fi

    print-header green "🧹 nuke: ${NUKE_CMD}"
    eval ${NUKE_CMD} || _error "Clean nuke failed: ${NUKE_CMD}"
elif (( flags[clean] )); then
    if [[ -z "${CLEAN_CMD}" ]]; then
        _error "CLEAN_CMD is not set. Check top of script to configure."
    fi

    print-header green "🧹 clean: ${CLEAN_CMD}"
    eval ${CLEAN_CMD} || _error "Clean failed: ${CLEAN_CMD}"
fi

if (( flags[install] )); then
    if [[ -z "${INSTALL_CMD}" ]]; then
        _error "INSTALL_CMD is not set. Check top of script to configure."
    fi

    print-header green "install: ${INSTALL_CMD}"
    eval ${INSTALL_CMD} || _error "Install failed: ${INSTALL_CMD}"
fi

if (( flags[aws_signon] )); then
    aws-signon dev || _error "aws-signon failed"
fi

if (( flags[db_up] )); then
    if [[ -z "${DB_UP_CMD}" ]]; then
        _error "DB_UP_CMD is not set. Check top of script to configure."
    fi

    print-header green "Starting DB Docker container"
    if [[ -z $DB_CONTAINER_ID ]]; then
        cd "${repo_dir}/${MIGRATIONS_SUBDIR}" > /dev/null
        eval ${DB_UP_CMD} || _error "Starting db failed: ${DB_UP_CMD}"
        cd "${repo_dir}" > /dev/null
    else
        echo "DB Docker container is already running"
    fi
fi

if (( flags[migration] )); then
    if [[ -z "${MIGRATIONS_CMD}" ]]; then
        _error "MIGRATIONS_CMD is not set. Check top of script to configure."
    fi

    print-header green "run-migration"
    cd "${repo_dir}/${MIGRATIONS_SUBDIR}" > /dev/null
    eval ${MIGRATIONS_CMD} || _error "Migration failed: ${MIGRATIONS_CMD}"
    cd "${repo_dir}" > /dev/null
fi

if (( flags[build] )); then
    if [[ -z "${BUILD_CMD}" ]]; then
        _error "BUILD_CMD is not set. Check top of script to configure."
    fi

    print-header green "build: ${BUILD_CMD}"
    eval ${BUILD_CMD} || _error "Build failed: ${BUILD_CMD}"
fi

if (( flags[unit_test] )); then
    if [[ -z "${UNIT_TESTS_CMD}" ]]; then
        # passing in -t/--test sets the unit_test flag, but shouldn't
        # fail if UNIT_TESTS_CMD is not set. If `test` is not set that
        # means the user specifically requested unit tests and we should
        # treat it as an error.
        if (( ! flags[test] )); then
            _error "UNIT_TESTS_CMD is not set. Check top of script to configure."
        else
            print-header yellow "UNIT_TESTS_CMD missing, skipping."
        fi
    fi

    print-header green "unit tests: ${UNIT_TESTS_CMD}"
    eval ${UNIT_TESTS_CMD} || _error "Tests failed: ${UNIT_TESTS_CMD}"
fi

if (( flags[integration_test] )); then
    if [[ -z "${INTEGRATION_TESTS_CMD}" ]]; then
        # passing in -t/--test sets the integration_test flag, but shouldn't
        # fail if INTEGRATION_TESTS_CMD is not set. If `test` is not set that
        # means the user specifically requested integration tests and we should
        # treat it as an error.
        if (( ! flags[test] )); then
            _error "INTEGRATION_TESTS_CMD is not set. Check top of script to configure."
        else
            print-header yellow "INTEGRATION_TESTS_CMD missing, skipping."
        fi
    else
        print-header green "integration tests: ${INTEGRATION_TESTS_CMD}"
        eval ${INTEGRATION_TESTS_CMD} || _error "Tests failed: ${INTEGRATION_TESTS_CMD}"
    fi
fi

print-header green "All steps completed successfully"
exit 0
