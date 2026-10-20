#!/usr/bin/env bash
#
# utils.sh
#
# Common utility functions.
# Project: 2026-backup-and-restore-server
#


if [[ -n "${UTILS_LOADED:-}" ]]; then
    return 0
fi

UTILS_LOADED=1


#######################################
# Command helpers
#######################################


command_exists()
{
    command -v "$1" >/dev/null 2>&1
}


require_command()
{
    local command_name="$1"


    if ! command_exists "${command_name}"; then

        if declare -F die >/dev/null 2>&1; then
            die "Required command not found: ${command_name}"
        fi

        printf \
            'Required command not found: %s\n' \
            "${command_name}" >&2

        return 1
    fi
}


#######################################
# Filesystem helpers
#######################################


is_file()
{
    [[ -f "$1" ]]
}


is_directory()
{
    [[ -d "$1" ]]
}


ensure_directory()
{
    local directory="$1"

    mkdir -p "${directory}"
}


safe_copy()
{
    local source="$1"
    local destination="$2"


    if [[ ! -e "${source}" ]]; then
        return 1
    fi


    mkdir -p "$(dirname "${destination}")"


    cp -a \
        "${source}" \
        "${destination}"
}


safe_move()
{
    local source="$1"
    local destination="$2"


    if [[ ! -e "${source}" ]]; then
        return 1
    fi


    mkdir -p "$(dirname "${destination}")"


    mv \
        "${source}" \
        "${destination}"
}


#######################################
# String helpers
#######################################


trim_string()
{
    local value="$*"

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    printf '%s' "${value}"
}


#######################################
# Time helpers
#######################################


get_timestamp()
{
    date '+%Y%m%d-%H%M%S'
}


generate_id()
{
    if command_exists uuidgen; then
        uuidgen
        return
    fi


    if [[ -r /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
        return
    fi


    date '+%s'
}


#######################################
# User interaction
#######################################


confirm()
{
    local message="$1"

    local answer


    read -r -p "${message} [y/N] " answer


    case "${answer}" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
