#!/usr/bin/env bash
# shellcheck shell=bash
set -eo pipefail

# Source core libraries
. "$(dirname "$0")/../lib/logger/core.bash"
. "$(dirname "$0")/../lib/bitwarden/core.bash"
. "$(dirname "$0")/../lib/gpg/core.bash"
. "$(dirname "$0")/../lib/yadm/core.bash"
. "$(dirname "$0")/../gig/vault/core.bash"


# @cmd Initialize secret management system
# @alias i
init() {
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
        "Initializing $(gum style --foreground 212 'gig-vault') secrets management"

    # Check existing state
    local state_file
    state_file=$(vault::state)

    if gum confirm "Found existing configuration - overwrite? $(jq . "$state_file")" \
        --affirmative="Overwrite" \
        --negative="Abort" \
        --prompt.border="normal" \
        --prompt.border-foreground=212 \
        --selected.background=212 ; then

        gum spin --title "Initializing vault" --spinner dot \
            -- sleep 10
    else
        logger::warn "Init aborted by user"
        return 1
    fi

    gum style --foreground 84 "Successfully initialized secret vault!"
}



eval "$(argc --argc-eval "$0" "$@")"
