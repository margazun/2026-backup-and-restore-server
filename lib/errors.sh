#!/usr/bin/env bash
#
# errors.sh
#
# Error handling framework.
# Project: 2026-backup-and-restore-server
#
# This library must not depend on other project libraries.
#


if [[ -n "${ERRORS_LOADED:-}" ]]; then
    return 0
fi

ERRORS_LOADED=1


#######################################
# Internal helpers
#######################################


_error_timestamp()
{
    date '+%Y-%m-%d %H:%M:%S'
}


_error_output()
{
    local message="$1"

    printf '%s ERROR: %s\n' \
        "$(_error_timestamp)" \
        "${message}" >&2
}


_error_stack_trace()
{
    local frame

    printf '%s\n' "Stack trace:" >&2

    for frame in "${FUNCNAME[@]:1}"; do
        printf '  -> %s\n' "${frame}" >&2
    done
}


#######################################
# Public API
#######################################


die()
{
    local message="$*"

    _error_output "${message}"

    exit 1
}


error_exit()
{
    local code="${1:-1}"
    shift || true

    local message="$*"


    if [[ -n "${message}" ]]; then
        _error_output "${message}"
    fi


    exit "${code}"
}


handle_error()
{
    local exit_code="$1"
    local line="$2"
    local command="$3"


    printf '\n' >&2

    _error_output \
        "Command failed"

    printf 'Exit code: %s\n' \
        "${exit_code}" >&2

    printf 'Line: %s\n' \
        "${line}" >&2

    printf 'Command: %s\n' \
        "${command}" >&2


    _error_stack_trace


    return "${exit_code}"
}


register_error_handler()
{
    trap \
        'handle_error $? ${LINENO} "${BASH_COMMAND}"' \
        ERR
}