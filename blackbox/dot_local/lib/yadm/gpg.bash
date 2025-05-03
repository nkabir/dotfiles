# yadm/gpg.bash
# This file is part of yadm.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_YADM_GPG" ] && return 0
_YADM_GPG=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::init
# create a new keypair in gpg with email yadm@secrets.github.com if it does not exist

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::gpg::init() {

    local gpg_id
    gpg_id=$(gpg::id "$YADM_GPG_EMAIL")

    if [[ -n $gpg_id ]]; then
        logger::info "GPG key for $YADM_GPG_EMAIL already exists"
        return 0
    fi

    logger::info "Creating new GPG keypair: $YADM_GPG_NAME <$YADM_GPG_EMAIL>"
    if gpg::create "$YADM_GPG_NAME" "$YADM_GPG_EMAIL"; then
        logger::info "Successfully created GPG keypair for YADM"
        return 0
    else
        logger::error "Failed to create GPG keypair"
        return 1
    fi
}



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::export
# export the keypair to files
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::gpg::export() {
    local export_dir="${YADM_HOME:-$HOME/.local/share/yadm}/gpg-keys"
    mkdir -p "$export_dir" || {
        logger::error "Failed to create export directory: $export_dir"
        return 1
    }

    local timestamp=$(date +%Y%m%dT%H%M%S)
    local email_safe=$(echo "$YADM_GPG_EMAIL" | tr '@' '_')

    # Get fingerprint first to verify key exists
    local gpg_id
    gpg_id=$(gpg::id "$YADM_GPG_EMAIL") || {
        logger::error "No GPG key found for $YADM_GPG_EMAIL"
        return 1
    }

    # Export private key
    local private_file="${export_dir}/${email_safe}-${timestamp}-private.asc"
    if ! gpg::export-private "$YADM_GPG_EMAIL" > "$private_file"; then
        logger::error "Failed to export private key for $YADM_GPG_EMAIL"
        return 1
    fi
    logger::info "Exported private key to: $private_file"

    # Create current symlink
    ln -sf "$(basename "$private_file")" "${export_dir}/${email_safe}-current-private.asc"

    # Export public key
    local public_file="${export_dir}/${email_safe}-${timestamp}-public.asc"
    if ! gpg::export-public "$YADM_GPG_EMAIL" > "$public_file"; then
        logger::error "Failed to export public key for $YADM_GPG_EMAIL"
        return 1
    fi
    logger::info "Exported public key to: $public_file"

    # Create current symlink
    ln -sf "$(basename "$public_file")" "${export_dir}/${email_safe}-current-public.asc"

    logger::info "GPG key exports completed successfully"
    return 0
}




# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::import
# import the keypair from files
