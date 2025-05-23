# gpg/private.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Export private key as armored text.
gpg::private::export() {
    local uid="$1"
    local export_path="$2"

    if [[ -z "$uid" || -z "$export_path" ]]; then
        logger::error "Usage: gpg::private::export <uid> <export_path>"
        return 1
    fi

    gpg --batch --yes --armor --export-secret-keys "$uid" > "$export_path"
    local status=$?

    if [[ $status -eq 0 ]]; then
        logger::info "Private key for UID '$uid' exported to '$export_path'"
    else
        logger::error "Failed to export private key for UID '$uid'"
        return $status
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Import private key from armored text.
gpg::private::import() {
    local import_path="$1"

    if [[ -z "$import_path" ]]; then
        logger::error "Usage: gpg::private::import <import_path>"
        return 1
    fi

    if [[ ! -f "$import_path" ]]; then
        logger::error "File not found: '$import_path'"
        return 2
    fi

    gpg --import "$import_path"
    local status=$?

    if [[ $status -eq 0 ]]; then
        logger::info "Private key imported from '$import_path'"
    else
        logger::error "Failed to import private key"
        return $status
    fi
}
