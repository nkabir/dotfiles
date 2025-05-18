# bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_CORE" ] && return 0
_BITWARDEN_CORE=1

BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${BITWARDEN_HERE}/../logger/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::logout() {

    bw logout
}
export -f bitwarden::logout


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::lock() {

    bw lock
}
export -f bitwarden::lock


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::sync() {

    # Sync the vault with the server
    if bw sync ; then
	logger::info "Bitwarden vault synced successfully."
    else
	logger::error "Failed to sync Bitwarden vault."
    fi

}
export -f bitwarden::sync


# :::::::::::::::::::::::::::::::::::::::::::::::::::
. "${BITWARDEN_HERE}/login.bash"
. "${BITWARDEN_HERE}/status.bash"
. "${BITWARDEN_HERE}/unlock.bash"
