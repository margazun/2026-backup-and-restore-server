#!/usr/bin/env bash
#
# bootstrap.sh
#
# Core initialization framework.
# Project: 2026-backup-and-restore-server
#
# Responsibilities:
#   - validate runtime environment
#   - locate project root
#   - load configuration
#   - initialize runtime directories
#   - register cleanup handlers
#   - load project libraries
#
# This file must not depend on other project libraries.
#

if [[ -n "${BOOTSTRAP_LOADED:-}" ]]; then
    return 0
fi

BOOTSTRAP_LOADED=1


#######################################
# Strict environment
#######################################

if [[ -z "${BASH_VERSION:-}" ]]; then
    printf '%s\n' "ERROR: Bash is required" >&2
    exit 1
fi


#######################################
# Constants
#######################################

readonly BOOTSTRAP_MIN_BASH_MAJOR=5


#######################################
# Internal state
#######################################

BOOTSTRAP_INITIALIZED=false
BOOTSTRAP_LOCK_FD=""


#######################################
# Private helpers
#######################################


_bootstrap_error()
{
    printf 'BOOTSTRAP ERROR: %s\n' "$*" >&2
}


_bootstrap_check_bash()
{
    local major

    major="${BASH_VERSINFO[0]}"

    if (( major < BOOTSTRAP_MIN_BASH_MAJOR )); then
        _bootstrap_error \
            "Bash ${BOOTSTRAP_MIN_BASH_MAJOR}+ required, found ${BASH_VERSION}"

        exit 1
    fi
}


_bootstrap_find_project_root()
{
    local source_file
    local source_dir

    source_file="${BASH_SOURCE[0]}"
    source_dir="$(cd "$(dirname "${source_file}")/.." && pwd)"

    PROJECT_ROOT="${source_dir}"

    export PROJECT_ROOT
}


_bootstrap_load_version()
{
    local version_file

    version_file="${PROJECT_ROOT}/VERSION"

    if [[ ! -f "${version_file}" ]]; then
        PROJECT_VERSION="unknown"
        export PROJECT_VERSION
        return
    fi

    PROJECT_VERSION="$(tr -d '[:space:]' < "${version_file}")"

    export PROJECT_VERSION
}


_bootstrap_load_config()
{
    PROJECT_CONFIG="${PROJECT_CONFIG_FILE:-${PROJECT_ROOT}/configs/project.conf}"

    export PROJECT_CONFIG

    if [[ -f "${PROJECT_CONFIG}" ]]; then
        # shellcheck disable=SC1090
        source "${PROJECT_CONFIG}"
    fi
}


_bootstrap_init_paths()
{
    PROJECT_NAME="${PROJECT_NAME:-2026-backup-and-restore-server}"

    PROJECT_RUNTIME="${PROJECT_RUNTIME:-${PROJECT_ROOT}/runtime}"

    PROJECT_LOG_DIR="${PROJECT_LOG_DIR:-${PROJECT_RUNTIME}/logs}"

    PROJECT_WORK_DIR="${PROJECT_WORK_DIR:-${PROJECT_RUNTIME}/work}"

    PROJECT_TEMP_DIR="${PROJECT_TEMP_DIR:-${PROJECT_RUNTIME}/tmp}"

    PROJECT_LOCK_DIR="${PROJECT_LOCK_DIR:-${PROJECT_RUNTIME}/locks}"

    PROJECT_BACKUP_DIR="${PROJECT_BACKUP_DIR:-${PROJECT_ROOT}/backups}"


    export PROJECT_NAME
    export PROJECT_RUNTIME
    export PROJECT_LOG_DIR
    export PROJECT_WORK_DIR
    export PROJECT_TEMP_DIR
    export PROJECT_LOCK_DIR
    export PROJECT_BACKUP_DIR
}


_bootstrap_create_directories()
{
    mkdir -p \
        "${PROJECT_RUNTIME}" \
        "${PROJECT_LOG_DIR}" \
        "${PROJECT_WORK_DIR}" \
        "${PROJECT_TEMP_DIR}" \
        "${PROJECT_LOCK_DIR}" \
        "${PROJECT_BACKUP_DIR}"
}


_bootstrap_check_root()
{
    if [[ "${EUID}" -ne 0 ]]; then
        _bootstrap_error \
            "This program must be run as root"

        exit 1
    fi
}


_bootstrap_cleanup()
{
    local exit_code=$?

    if [[ -n "${PROJECT_TEMP_DIR:-}" ]]; then
        if [[ -d "${PROJECT_TEMP_DIR}" ]]; then
            rm -rf "${PROJECT_TEMP_DIR:?}"/*
        fi
    fi


    if [[ -n "${BOOTSTRAP_LOCK_FD}" ]]; then
        eval "exec ${BOOTSTRAP_LOCK_FD}>&-" || true
    fi


    return "${exit_code}"
}


_bootstrap_register_traps()
{
    trap '_bootstrap_cleanup' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
}


_bootstrap_load_libraries()
{
    local lib_dir

    lib_dir="${PROJECT_ROOT}/lib"


    local libraries=(
        "logger.sh"
        "errors.sh"
        "utils.sh"
        "manifest.sh"
        "archive.sh"
        "crypto.sh"
        "module.sh"
    )


    local library

    for library in "${libraries[@]}"; do

        if [[ -f "${lib_dir}/${library}" ]]; then
            # shellcheck disable=SC1090
            source "${lib_dir}/${library}"
        fi

    done
}


_bootstrap_create_lock()
{
    local name

    name="${1:-default}"

    local lock_file

    lock_file="${PROJECT_LOCK_DIR}/${name}.lock"


    exec {BOOTSTRAP_LOCK_FD}>"${lock_file}"

    if ! flock -n "${BOOTSTRAP_LOCK_FD}"; then
        _bootstrap_error \
            "Another process is already running: ${name}"

        exit 1
    fi
}


#######################################
# Public API
#######################################


bootstrap()
{
    if [[ "${BOOTSTRAP_INITIALIZED}" == "true" ]]; then
        return 0
    fi


    _bootstrap_check_bash

    _bootstrap_find_project_root

    _bootstrap_load_version

    _bootstrap_load_config

    _bootstrap_init_paths

    _bootstrap_create_directories

    _bootstrap_check_root

    _bootstrap_register_traps

    _bootstrap_load_libraries


    BOOTSTRAP_INITIALIZED=true

    export BOOTSTRAP_INITIALIZED
}


cleanup()
{
    _bootstrap_cleanup
}


create_lock()
{
    _bootstrap_create_lock "$@"
}