# yadm/bitwarden.bash
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# This file is part of yadm.

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::bitwarden::init
# ensure yadm folder exists
# ensure secrets.github.com note exists
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::bitwarden::init() {
    # Create yadm folder if needed
    if ! bitwarden::folder::id "yadm" >/dev/null; then
        logger::info "Creating Bitwarden 'yadm' folder"
        if ! bitwarden::folder::create "yadm"; then
            logger::error "Failed to create Bitwarden 'yadm' folder"
            return 1
        fi
    fi

    # Create secrets.github.com note if needed
    # check if bitwarden::note::id "secrets.github.com" exists
    # if not, create it
    local note_id=
    note_id=$(bitwarden::note::id "secrets.github.com")
    if [[ -z $note_id ]]; then
        logger::info "Creating 'secrets.github.com' secure note"
        if ! bitwarden::note::create "secrets.github.com" "yadm" "Managed with scripts. Do not edit."; then
            logger::error "Failed to create 'secrets.github.com' secure note"
            return 2
        fi
    fi

    logger::info "Bitwarden yadm initialization complete"
    return 0
}



# yadm::bitwarden::restore
# download attachments from secrets.github.com

# yadm::bitwarden::backup
# upload attachments to secrets.github.com
