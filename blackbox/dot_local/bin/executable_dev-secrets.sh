#!/usr/bin/env bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
set -eo pipefail

# Source core libraries
. "$(dirname "$0")/../lib/logger/core.bash"
. "$(dirname "$0")/../gig/bitwarden/core.bash"

# @cmd login to Bitwarden vault
# @alias l
# @flag -h --help Show help
# @arg rest* Additional arguments for the command
login() {

    gig::bitwarden::login "$@"

}

# @cmd logout from Bitwarden vault
# @alias lo
# @flag -h --help Show help
# @arg rest* Additional arguments for the command
logout() {

    gig::bitwarden::logout "$@"

}


# @cmd sync Bitwarden vault and local files
# @alias s
# @flag -h --help Show help
# @arg rest* Additional arguments for the command
sync() {

    gig::bitwarden::sync "$@"
    gig::bitwarden::sync-ssh-keys

}


# @cmd sync-ssh-key Sync SSH key from Bitwarden
# @alias ss
# @flag -h --help Show help
# @arg key SSH key to sync
sync-ssh-key() {

    local key="$1"

    if [[ -z "$key" ]]; then
        logger::error "SSH key not specified"
        return 1
    fi

    gig::bitwarden::sync-ssh-key "$key" "$@"

}

eval "$(argc --argc-eval "$0" "$@")"
