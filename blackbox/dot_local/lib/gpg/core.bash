# gpg/core.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# GPG Key Management Functions
#
# This script provides functions to manage GPG keys, including creating,
# deleting, and exporting keys. It also includes a function to retrieve
# the fingerprint of a GPG key associated with a given email address.
#
#
[ -n "$_GPG_CORE" ] && return 0
_GPG_CORE=1

GPG_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${GPG_HERE:?}/../logger/core.bash"
. "${GPG_HERE:?}/public.bash"
. "${GPG_HERE:?}/private.bash"
. "${GPG_HERE:?}/primary.bash"



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Check if GPG is installed and configured for SSH
gpg::init() {

    # Check if gpg is installed
    if ! command -v gpg &> /dev/null; then
	yadm::log::error "gpg is not installed. Please install it to use yadm."
	return 1
    fi

    # Check if gpg-agent is running
    if ! pgrep -x "gpg-agent" > /dev/null; then
	yadm::log::error "gpg-agent is not running. Please start it to use yadm."
	return 1
    fi

    # Check if gpg is configured for SSH
    if ! gpgconf --list-dirs agent-ssh-socket > /dev/null; then
	yadm::log::error "gpg is not configured for SSH. Please configure it to use yadm."
	return 1
    fi

    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Retrieve the GPG key fingerprint for a given email address
gpg::id() {


    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::fingerprint "
        return 1
    fi

    gpg --with-colons --fingerprint "$email" | awk -F: '/^fpr:/ {print $10; exit}'
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# List all GPG keys
gpg::list() {

    gpg --list-secret-keys --with-colons | awk -F'[<>]' '/^uid:/ {print $2}'
}



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Export the private key in armored format
gpg::export-private() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::export-armored-private-key <email-address>"
        return 1
    fi

    gpg --armor --export-secret-keys "$email"
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Export the public key in armored format
gpg::export-public() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::export-public <email-address>"
        return 1
    fi

    gpg --armor --export "$email"
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Delete a GPG key pair
gpg::delete() {

    local email="$1"
    if [[ -z "$email" ]]; then
        logger::error "Usage: gpg::delete-key-pair <email-address>"
        return 1
    fi

    # Get fingerprint of the key for the given email
    local fingerprint
    fingerprint="$(gpg::id "$email")"
    if [[ -z "$fingerprint" ]]; then
        logger::warn "No GPG key found for email: $email"
        return 0
    fi

    logger::info "Deleting secret key for $email (fingerprint: $fingerprint)"
    # Delete secret key (private key)
    if ! echo "y" | gpg --batch --yes --delete-secret-key "$fingerprint"; then
        logger::error "Failed to delete secret key for $email"
        return 1
    fi

    logger::info "Deleting public key for $email (fingerprint: $fingerprint)"
    # Delete public key
    if ! echo "y" | gpg --batch --yes --delete-key "$fingerprint"; then
        logger::error "Failed to delete public key for $email"
        return 1
    fi

    logger::info "Successfully deleted GPG key pair for $email"
    return 0
}
