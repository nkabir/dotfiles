# account.bash
#
# Bitwarden account
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::

[ -n "$_BITWARDEN_ACCOUNT" ] && return 0
_BITWARDEN_ACCOUNT=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::account::is-unlocked() {
    if [[ -z "${BW_SESSION}" ]]; then

	logger::warn "Bitwarden session is not unlocked"
	return 1
    fi
    return 0
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::account::sync() {

    logger::info "Syncing Bitwarden account"
    bw sync
}
