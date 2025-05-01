# yadm.bash
# yadm - Yet Another Dotfiles Manager
YADM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${YADM_HERE:?}/logger.bash"
. "${YADM_HERE:?}/gpg.bash"

# YADM_GPG - GPG key to use for encryption
YADM_GPG_EMAIL="yadm@localhost"


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
