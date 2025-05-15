#!/usr/bin/env bash
# shellcheck shell=bash

# Source core libraries
. "$(dirname "$0")/../lib/logger/core.bash"
. "$(dirname "$0")/../lib/bitwarden/core.bash"
. "$(dirname "$0")/../lib/gpg/core.bash"
. "$(dirname "$0")/../lib/yadm/core.bash"
. "$(dirname "$0")/../gig/vault/core.bash"


# @arg command[init] Command to run: init
# @arg rest* Additional arguments for the command

# Import argc's argument parsing
eval "$(argc --argc-eval "$0" "$@")"

init() {
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
        "Initializing $(gum style --foreground 212 'gig-vault') secrets management"

    gum spin --show-output --title "Assembling state..." -- $(vault::state)

}


case "$argc_command" in
    init)
        init
        ;;
    *)
        logger::error "Unknown command: $argc_command"
        exit 1
        ;;
esac
