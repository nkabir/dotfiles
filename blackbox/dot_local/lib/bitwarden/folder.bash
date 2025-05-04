# folder.bash
# Manages folders on BitWarden
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_FOLDER" ] && return 0
_BITWARDEN_FOLDER=1

# TODO add an update method that changes the name of a folder given an
# id


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::folder::json() {

    local folder_name="$1"
    echo $(cat <<EOF
{
    "name": "$folder_name"
}
EOF
	  )
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::folder::id() {

    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::read-folder-by-name <folder_name>"
        return 1
    fi

    local folder_id
    folder_id="$(bw list folders | jq -r --arg name "$folder_name" '.[] | select(.name == $name) | .id')"

    if [[ -n "$folder_id" ]]; then
        echo "$folder_id"
    fi

    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::folder::create() {

    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::folder::create <folder_name>"
        return 1
    fi

    # Try to get the folder id
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -n "$folder_id" ]]; then
        echo "$folder_id"
        return 0
    fi

    # Folder does not exist, create it
    logger::info "Creating Bitwarden folder '$folder_name'"
    local create_result
    local folder_json="$(bitwarden::folder::json "$folder_name")"

    create_result="$(echo "$folder_json" | bw encode | bw create folder)"
    if [[ $? -ne 0 ]]; then
        logger::error "Failed to create Bitwarden folder '$folder_name': $create_result"
        return 2
    fi

    folder_id="$(echo "$create_result" | jq -r '.id')"
    if [[ -n "$folder_id" && "$folder_id" != "null" ]]; then
        echo "$folder_id"
        return 0
    else
        logger::error "Could not extract folder id after creation for '$folder_name'"
        return 3
    fi
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::folder::delete() {

    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::folder::delete <folder_name>"
        return 1
    fi

    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::warn "Bitwarden folder '$folder_name' does not exist."
        return 0
    fi

    logger::info "Deleting Bitwarden folder '$folder_name' (id: $folder_id)"
    local result
    result="$(bw delete folder "$folder_id" 2>&1)"
    if [[ $? -eq 0 ]]; then
        logger::info "Successfully deleted Bitwarden folder '$folder_name'"
        return 0
    else
        logger::error "Failed to delete Bitwarden folder '$folder_name': $result"
        return 2
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::folder::list() {
    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::folder::list <folder-name>"
        return 1
    fi

    # Get folder ID
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::error "Folder '$folder_name' not found"
        return 2
    fi

    # List secure notes (type=2) in folder
    local notes
    notes=$(bw list items --folderid "$folder_id" | jq -r '.[] | select(.type == 2) | .name')

    if [[ -z "$notes" ]]; then
        logger::info "No secure notes found in folder '$folder_name'"
        return 0
    fi

    echo "$notes"
}
