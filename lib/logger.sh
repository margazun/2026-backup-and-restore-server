#!/usr/bin/env bash

# Logger library
# Part of 2026-backup-and-restore-server


if [[ -n "${LOGGER_LOADED:-}" ]]; then
    return 0
fi

LOGGER_LOADED=1


#######################################
# Defaults
#######################################

: "${PROJECT_LOG_LEVEL:=INFO}"
: "${PROJECT_COLOR:=true}"

: "${PROJECT_LOG_FILE:=}"


#######################################
# Internal
#######################################

_LOG_LEVEL_NUM_DEBUG=0
_LOG_LEVEL_NUM_INFO=1
_LOG_LEVEL_NUM_WARN=2
_LOG_LEVEL_NUM_ERROR=3
_LOG_LEVEL_NUM_SUCCESS=1


logger_level_to_num()
{
    case "$1" in
        DEBUG)
            echo "${_LOG_LEVEL_NUM_DEBUG}"
            ;;
        INFO)
            echo "${_LOG_LEVEL_NUM_INFO}"
            ;;
        WARN)
            echo "${_LOG_LEVEL_NUM_WARN}"
            ;;
        ERROR)
            echo "${_LOG_LEVEL_NUM_ERROR}"
            ;;
        SUCCESS)
            echo "${_LOG_LEVEL_NUM_SUCCESS}"
            ;;
        *)
            echo "${_LOG_LEVEL_NUM_INFO}"
            ;;
    esac
}


logger_should_print()
{
    local level="$1"

    local current
    current=$(logger_level_to_num "${PROJECT_LOG_LEVEL}")

    local message
    message=$(logger_level_to_num "${level}")

    [[ "${message}" -ge "${current}" ]]
}


logger_timestamp()
{
    date '+%Y-%m-%d %H:%M:%S'
}


logger_color()
{
    local level="$1"

    if [[ "${PROJECT_COLOR}" != "true" ]]; then
        return
    fi

    if [[ ! -t 1 ]]; then
        return
    fi

    case "${level}" in

        DEBUG)
            printf '\033[90m'
            ;;

        INFO)
            printf '\033[36m'
            ;;

        WARN)
            printf '\033[33m'
            ;;

        ERROR)
            printf '\033[31m'
            ;;

        SUCCESS)
            printf '\033[32m'
            ;;

    esac
}


logger_color_reset()
{
    if [[ "${PROJECT_COLOR}" == "true" ]] && [[ -t 1 ]]; then
        printf '\033[0m'
    fi
}


#######################################
# Public API
#######################################


logger_init()
{
    if [[ -z "${PROJECT_LOG_FILE}" ]]; then
        return 0
    fi

    mkdir -p "$(dirname "${PROJECT_LOG_FILE}")"

    touch "${PROJECT_LOG_FILE}"
}


log()
{
    local level="$1"
    shift

    local message="$*"

    if ! logger_should_print "${level}"; then
        return 0
    fi


    local timestamp
    timestamp=$(logger_timestamp)


    local line

    line="${timestamp} [${level}] ${message}"


    # File output
    if [[ -n "${PROJECT_LOG_FILE}" ]]; then
        printf '%s\n' "${line}" >> "${PROJECT_LOG_FILE}"
    fi


    # Console output

    logger_color "${level}"

    printf '%s [%s] %s' \
        "${timestamp}" \
        "${level}" \
        "${message}"

    logger_color_reset

    printf '\n'
}


log_debug()
{
    log DEBUG "$*"
}


log_info()
{
    log INFO "$*"
}


log_warn()
{
    log WARN "$*"
}


log_error()
{
    log ERROR "$*"
}


log_success()
{
    log SUCCESS "$*"
}