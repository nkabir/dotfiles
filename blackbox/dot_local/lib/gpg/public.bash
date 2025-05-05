# gpg/public.bash
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::w


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# export a public key
gpg::public::export() {
    local uid="$1"
    local output_path="$2"

    if [[ -z "$uid" || -z "$output_path" ]]; then
        logger::error "Usage: gpg::public::export-key <uid> <output_path>"
        return 1
    fi

    if ! gpg --list-keys "$uid" &>/dev/null; then
        logger::error "No public key found for UID: $uid"
        return 2
    fi

    if ! gpg --armor --export "$uid" > "$output_path"; then
        logger::error "Failed to export public key for UID: $uid"
        return 3
    fi

    logger::info "Exported public key for UID '$uid' to '$output_path'"
}
