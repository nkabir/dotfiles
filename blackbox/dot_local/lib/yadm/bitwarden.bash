# yadm/bitwarden.bash
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# This file is part of yadm.

. "${YADM_HERE:?}/../logger/core.bash"
. "${YADM_HERE:?}/../bitwarden/core.bash"

FOLDER_NAME="yadm"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::bitwarden::list
# Lists all backups in the yadm folder
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
yadm::bitwarden::list() {

    local folder_name="${FOLDER_NAME:?}"
    logger::info "Listing Bitwarden folder '$folder_name'"
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -n "$folder_id" ]]; then
	bitwarden::folder::list "$folder_name"
    else
	logger::error "Failed to list Bitwarden folder '$folder_name'"
	return 1
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::bitwarden::init
# ensure yadm folder exists
#   ensure notes exist in the folder
#     ensure attachments exist in the notes
# download attachments
# load attachments into gpg
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::bitwarden::init
# Ensures the "yadm" folder exists in Bitwarden
# Ensures there's a note with two attachemnts, public.asc and private.asc
yadm::bitwarden::init() {

    local folder_name="${FOLDER_NAME:?}"
    logger::info "Ensuring Bitwarden folder '$folder_name' exists"
    local folder_id
    folder_id="$(bitwarden::folder::create "$folder_name")"
    if [[ -n "$folder_id" ]]; then
        logger::info "Bitwarden folder '$folder_name' exists (id: $folder_id)"
    else
        logger::error "Failed to ensure Bitwarden folder '$folder_name' exists"
        return 1
    fi


}



# yadm::bitwarden::list # list backups in yadm folder
  # bitwarden::folder::list yadm

# yadm::bitwarden::restore
# download current attachments from secrets.github.com

# yadm::bitwarden::backup
# upload attachments to secrets.github.com
