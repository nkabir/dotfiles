# account.bash
#
# Bitwarden account
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Returns the Bitwarden session ID or nothing
bitwarden::account::session() {

    echo $BW_SESSION
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Returns true if session is unlocked
bitwarden::account::is-unlocked() {
    if [[ -z "$(bitwarden::account::session)" ]]; then

	logger::warn "Bitwarden session is not unlocked"
	return 1
    fi
    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Unlocks the Bitwarden account
# NOTE this may be better handled by default bitwarden commands
# to avoid security issues
#
bitwarden::account::unlock() {

    logger::info "Unlocking Bitwarden account"
    read -s -p "Enter Bitwarden password: " password
    echo
    local session
    session=$(echo "$password" | bw unlock --raw 2>/dev/null)
    if [[ $? -ne 0 ]]; then
	logger::error "Failed to unlock Bitwarden account"
	return 1
    fi
    export BW_SESSION="$session"
    unset password
    logger::info "Bitwarden account unlocked"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Synchronizes the Bitwarden account
bitwarden::account::sync() {

    logger::info "Syncing Bitwarden account"
    bw sync
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::account::list-folders() {
    logger::info "Listing all Bitwarden folder names"
    local folders
    folders=$(bw list folders 2>/dev/null | jq -r '.[].name')
    if [[ -z "$folders" ]]; then
        logger::info "No folders found in Bitwarden vault."
        return 0
    fi
    echo "$folders"
}
