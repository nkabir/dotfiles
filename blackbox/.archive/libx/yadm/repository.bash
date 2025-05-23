# yadm/repository.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# initialize yadm repository
yadm::repository::init() {

    local gpg_uid="$1"
    local repository="secrets"

    # check parameters
    if [[ -z "$gpg_uid" || -z "$repository" ]]; then
	logger::error "Usage: yadm::repository::init <gpg-key> <repository>"
	return 1
    fi

    # Initialize YADM
    if ! yadm init >/dev/null 2>&1 ; then
	logger::error "YADM repository already exists"
    else
	logger::info "YADM repository initialized"
	logger::info "#######################################################"
	logger::info "Please create a private repository on GitHub: $repository"
	logger::info "Then run: yadm remote add origin <repository-url>"
	logger::info "#######################################################"
    fi

    # Set GPG recipient
    yadm config yadm.gpg-recipient "$gpg_uid"

}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# sync yadm repository
yadm::repository::sync() {
    # Pull latest changes
    yadm pull --rebase || true

    # Check for uncommitted changes
    if [ -n "$(yadm status --porcelain)" ]; then
        # Encrypt and commit
        yadm encrypt
	yadm add -u
        yadm commit -m "Sync from $(hostname)"
        yadm push
        logger::info "Changes pushed to remote"
    else
        logger::info "Already up to date"
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# rotate GPG key used to encrypt yadm repository
yadm::repository::rekey() {

    local uid
    uid=$(yadm::gpg::uid)

    # Get current key information
    local old_fingerprint
    old_fingerprint=$(gpg::primary::id "$uid")
    old_note="$(gpg::backup::name "$uid")"

    logger::info "Current GPG key: $old_fingerprint"
    logger::info "Current UID : $uid"
    logger::info "Current Note: $old_note"

    # Find repository from Bitwarden
    local items
    items=$(bw list items --search "$old_note")

    if [ "$(echo "$items" | jq length)" -eq 0 ]; then
        logger::error "Could not find current key in Bitwarden"
        return 1
    fi

    yadm decrypt


    # Generate new key
    yadm::gpg::delete
    logger::info "Deleted old GPG key: $old_fingerprint"

    yadm::gpg::create
    logger::info "Generated new GPG key: $new_fingerprint"

    # Re-encrypt with new key
    yadm encrypt

    # Backup new key
    # backup_to_bitwarden "$new_fingerprint" "$repository"
    gpg::backup::bitwarden "$uid" gig.vault

    # Commit and push
    yadm add -u
    yadm commit -m "Rotate GPG key to ${new_fingerprint:0:16}"
    yadm push

    logger::info "Key rotation complete"

    return 0
}
