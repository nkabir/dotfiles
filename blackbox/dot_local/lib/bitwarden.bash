# bitwarden.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Bitwarden CLI script for Linux

BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. ${BITWARDEN_HERE:?}/logger.bash


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::is-unlocked() {
    local status=$(bw status | jq -r '.status')
    if [ "$status" != "unlocked" ]; then
        logger::error "BitWarden is locked. Please login using 'bw login' or unlock with 'bw unlock'" 3
        return 1
    fi
    return 0
}

# Replace the initial checks with:
if ! command -v bw &> /dev/null; then
    bw_error "BitWarden CLI is not installed" 2
    return 2
fi

# Check if user is logged in
# bitwarden::is-unlocked || return $?


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::sync() {
    bw sync
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::read-folder() {
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
bitwarden::create-folder() {

    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::create-folder-exists "
        return 1
    fi

    # Try to get the folder id
    local folder_id
    folder_id="$(bitwarden::read-folder "$folder_name")"
    if [[ -n "$folder_id" ]]; then
        echo "$folder_id"
        return 0
    fi

    # Folder does not exist, create it
    logger::info "Creating Bitwarden folder '$folder_name'"
    local create_result
    local folder_json=$(jq -n \
			--arg name "$folder_name" \
			      '{ name: $name }'
    )
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
bitwarden::delete-folder() {
    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::delete-folder <folder_name>"
        return 1
    fi

    local folder_id
    folder_id="$(bitwarden::read-folder "$folder_name")"
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
bitwarden::read-item() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        logger::error "Usage: bitwarden::read-item <search_term>"
        return 1
    fi

    local result
    result="$(bw get item "$search_term" 2>&1)"
    if [[ "$result" == "Not found."* ]]; then
        logger::debug "Bitwarden item '$search_term' not found."
        return 1
    elif [[ "$result" == *"More than one result"* ]]; then
        logger::warn "Multiple Bitwarden items found for '$search_term', refusing to return ambiguous id."
        return 1
    elif [[ "$result" == "You must unlock your vault"* ]]; then
        logger::error "Bitwarden vault is locked. Please unlock before continuing."
        return 2
    else
        local id
        id="$(echo "$result" | jq -r '.id' 2>/dev/null)"
        if [[ -n "$id" && "$id" != "null" ]]; then
            echo "$id"
            return 0
        else
            logger::error "Failed to extract Bitwarden item id for '$search_term'."
            return 1
        fi
    fi
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::create-note() {
    local note_name="$1"
    local folder_name="$2"
    local note_content="$3"

    if [[ -z "$note_name" || -z "$folder_name" || -z "$note_content" ]]; then
        logger::error "Usage: bitwarden::create-note <note_name> <folder_name> <note_content>"
        return 1
    fi

    # Ensure folder exists and get its ID
    local folder_id
    folder_id="$(bitwarden::create-folder "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::error "Failed to get or create folder '$folder_name'"
        return 2
    fi

    # Prepare note JSON
    local note_json
    note_json=$(jq -n \
        --arg type "2" \
        --arg name "$note_name" \
        --arg notes "$note_content" \
        --arg folderId "$folder_id" \
        '{type: ($type | tonumber), secureNote: { type: 0}, name: $name, notes: $notes, folderId: $folderId}'
    )

    # Create note
    local result
    result="$(echo "$note_json" | bw encode | bw create item 2>&1)"
    if [[ $? -eq 0 ]]; then
        logger::info "Successfully created note '$note_name' in folder '$folder_name'"
        return 0
    else
        logger::error "Failed to create note '$note_name': $result"
        return 3
    fi
}
