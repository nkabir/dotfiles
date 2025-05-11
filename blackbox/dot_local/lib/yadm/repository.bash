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
	log_error "Usage: yadm::repository::init <gpg-key> <repository>"
	return 1
    fi

    # Initialize YADM
    if ! yadm init >/dev/null 2>&1 ; then
	logger::error "YADM repository already exists"
    fi

    # Set GPG recipient
    yadm config yadm.gpg-recipient "$gpg_uid"

    logger::info "YADM repository initialized"
    logger::info "#######################################################"
    logger::info "Please create a private repository on GitHub: $repository"
    logger::info "Then run: yadm remote add origin <repository-url>"
    logger::info "#######################################################"

}
