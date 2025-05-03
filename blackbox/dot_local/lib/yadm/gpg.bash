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
# yadm::gpg::backup
# export the keypair to files


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::restore
# import the keypair from files
