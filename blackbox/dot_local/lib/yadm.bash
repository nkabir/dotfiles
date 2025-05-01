# yadm.bash
# yadm - Yet Another Dotfiles Manager
YADM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

. "${YADM_HERE:?}/logger.bash"
. "${YADM_HERE:?}/gpg.bash"

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::gpg-id-exists() {
    local email="${YADM_GPG_EMAIL:?}"
    local fingerprint
    fingerprint="$(gpg::get-fingerprint "$email" 2>/dev/null)"
    if [[ -n "$fingerprint" ]]; then
        logger::info "GPG identity '$email' exists (fingerprint: $fingerprint)."
        return 0
    else
        logger::warn "GPG identity '$email' does not exist."
        return 1
    fi
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::delete-gpg-key() {
    local email="${YADM_GPG_EMAIL:?}"
    local fingerprint
    fingerprint="$(gpg::get-fingerprint "$email" 2>/dev/null)"
    
    if [[ -n "$fingerprint" ]]; then
        logger::info "Deleting GPG key pair for '$email' (fingerprint: $fingerprint)"
        if gpg::delete-key-pair "$fingerprint"; then
            logger::info "Successfully deleted GPG key pair"
        else
            logger::error "Failed to delete GPG key pair"
            return 1
        fi
    else
        logger::warn "No GPG key pair found for '$email'"
    fi
}
