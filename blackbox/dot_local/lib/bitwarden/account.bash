# account.bash
#
# Bitwarden account
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


bitwarden::account::is-unlocked() {
    if [[ -z "${BW_SESSION}" ]]; then

	logger::warn "Bitwarden session is not unlocked"
	return 1
    fi
    return 0
}
