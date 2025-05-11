# gpg/restore.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# restore from bitwarden
gpg::restore::bitwarden() {
    local folder_name="$1"
    local temp_dir="$(mktemp -d)"

    # Get latest note name
    local latest_note
    latest_note="$(bitwarden::folder::list "$folder_name" | head -n 1)"
    if [[ -z "$latest_note" ]]; then
        logger::error "No notes found in Bitwarden folder: $folder_name"
        return 1
    fi

    # Download private key attachment
    local private_key_path="${temp_dir}/private.asc"
    if ! bitwarden::attachment::download "$latest_note" "private.asc" "$private_key_path"; then
        logger::error "Failed to download private.asc from note: $latest_note"
        return 2
    fi

    # Extract fingerprint from note name (format: SHORTFP.REPO)
    local short_fingerprint="${latest_note%%.*}"
    local full_fingerprint
    full_fingerprint="$(gpg::primary::list | grep -i "$short_fingerprint")"

    # Only import if key doesn't exist
    if [[ -z "$full_fingerprint" ]]; then
        logger::info "Importing GPG private key from Bitwarden"
        if ! gpg::private::import "$private_key_path"; then
            logger::error "Failed to import private key"
            return 3
        fi

        # Get full fingerprint after import
        full_fingerprint="$(gpg::primary::list | grep -i "$short_fingerprint")"
        if [[ -z "$full_fingerprint" ]]; then
            logger::error "Failed to verify imported key fingerprint"
            return 4
        fi
    fi

    # Set ultimate trust (non-interactive)
    logger::info "Setting ultimate trust for key: ${full_fingerprint}"
    echo -e "trust\n5\ny\nquit\n" | gpg --batch --command-fd 0 --edit-key "$full_fingerprint"

    # Cleanup
    shred -u "$private_key_path"
    rmdir "$temp_dir"

    logger::info "Successfully restored GPG key from Bitwarden: ${full_fingerprint}"
    return 0
}
