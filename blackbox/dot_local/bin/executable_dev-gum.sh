#!/usr/bin/env bash
# shellcheck shell=bash



# @flag -h --help Show help
# @arg command[init] Command to run: init
# @arg rest* Additional arguments for the command

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    export SHOWING_HELP=1
    # argc --argc-eval "$0" --help | gum style --border double --padding "1 2" --foreground 212
    argc --argc-eval "$0" --help
    exit 0
fi


# Import argc's argument parsing
# Only run argc normally if not showing help
if [[ -z "$SHOWING_HELP" ]]; then
  eval "$(argc --argc-eval "$0" "$@")"
fi

# Source core libraries
. "$(dirname "$0")/../lib/logger/core.bash"
. "$(dirname "$0")/../lib/bitwarden/core.bash"
. "$(dirname "$0")/../lib/gpg/core.bash"
. "$(dirname "$0")/../lib/yadm/core.bash"
. "$(dirname "$0")/../gig/vault/core.bash"



func() {
    sleep 5
    echo "Hello, World!"
}
export -f func


init() {

    result=$(gum spin -- bash -c vault::state)
    echo "Result: $result"

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
