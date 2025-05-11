# bitwarden/note.bash
# This script is used to create a note in Bitwarden
# It requires the Bitwarden CLI to be installed and configured.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::json() {
    local name="$1"
    local folder_id="$2"
    local content="$3"

    if [[ -z "$name" || -z "$folder_id" || -z "$content" ]]; then
	logger::error "Usage: bitwarden::note::json <name> <folder_id> <content>"
	return 1
    fi

    # Prepare note JSON
    echo $(cat <<EOF
{
  "type": 2,
  "name": "$name",
  "notes": "$content",
  "folderId": "$folder_id",
  "secureNote": {
    "type": 0
  }
}
EOF
	  )
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::id() {

    local note_name="$1"
    if [[ -z "$note_name" ]]; then
        logger::error "Usage: bitwarden::note::id <note_name>"
        return 1
    fi

    # Get the item ID by note name
    local item_id
    item_id="$(bitwarden::item::id "$note_name")"
    if [[ -n "$item_id" ]]; then
	echo "$item_id"
	return 0
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::create() {
    local note_name="$1"
    local folder_name="$2"
    local note_content="$3"

    if [[ -z "$note_name" || -z "$folder_name" || -z "$note_content" ]]; then
        logger::error "Usage: bitwarden::note::create <note_name> <folder_name> <note_content>"
        return 1
    fi

    # Ensure folder exists and get its ID
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::error "Failed to get or create folder '$folder_name'"
        return 2
    fi

    # Prepare note JSON
    local note_json
    note_json="$(bitwarden::note::json "$note_name" "$folder_id" "$note_content")"

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


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::delete() {
    local note_name="$1"
    if [[ -z "$note_name" ]]; then
        logger::error "Usage: bitwarden::note::delete <note_name>"
        return 1
    fi

    # Get the item ID by note name
    local item_id
    item_id="$(bitwarden::note::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::warn "Note named '$note_name' not found."
        return 0
    fi

    # Delete the item by ID
    local result
    result="$(bw delete item "$item_id" 2>&1)"
    if [[ $? -eq 0 ]]; then
        logger::info "Successfully deleted note '$note_name' (id: $item_id)"
        return 0
    else
        logger::error "Failed to delete note '$note_name': $result"
        return 2
    fi
}


# In blackbox/dot_local/lib/bitwarden/note.bash

# Add after the bitwarden::note::delete function
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::move() {
    local note_name="$1"
    local folder_name="$2"

    if [[ -z "$note_name" || -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::note::move <note_name> <folder_name>"
        return 1
    fi

    # Get note ID
    local item_id
    item_id="$(bitwarden::note::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::error "Note '$note_name' not found"
        return 2
    fi

    # Get folder ID
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::error "Folder '$folder_name' not found"
        return 3
    fi

    # Get current item JSON and update folderId
    local updated_json
    if ! updated_json=$(bw get item "$item_id" | jq --arg fid "$folder_id" '.folderId = $fid'); then
        logger::error "Failed to update folder ID in note JSON"
        return 4
    fi

    # Apply changes
    if echo "$updated_json" | bw encode | bw edit item "$item_id" >/dev/null 2>&1; then
        logger::info "Moved note '$note_name' to folder '$folder_name'"
        return 0
    else
        logger::error "Failed to update note '$note_name'"
        return 5
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::note::list() {
    local note_name="$1"
    if [[ -z "$note_name" ]]; then
        logger::error "Usage: bitwarden::note::list-attachments <note-name>"
        return 1
    fi

    # Get the item ID for the note name
    local item_id
    item_id="$(bitwarden::note::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::warn "Note named '$note_name' not found."
        return 0
    fi

    # Get the item JSON and extract attachment file names
    local attachments
    attachments="$(bw get item "$item_id" | jq -r '.attachments[]?.fileName')"

    if [[ -z "$attachments" ]]; then
        logger::info "No attachments found for note '$note_name'."
        return 0
    fi

    echo "$attachments"
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Downloads the latest note (by last revision date) in a given folder.
# Returns the note name.
bitwarden::note::latest() {
    local folder_name="$1"

    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::note::latest <folder_name>"
        return 1
    fi

    # Get folder ID
    local folder_id
    folder_id="$(bitwarden::folder::id "$folder_name")"
    if [[ -z "$folder_id" ]]; then
        logger::error "Folder '$folder_name' not found"
        return 2
    fi

    # Find the latest note by revision date in the folder
    local note_json
    note_json="$(bw list items --folderid "$folder_id" | jq -r '[.[] | select(.type == 2)] | sort_by(.revisionDate) | reverse | .[0]')"
    if [[ -z "$note_json" || "$note_json" == "null" ]]; then
        logger::warn "No notes found in folder '$folder_name'"
        return 3
    fi

    local note_name
    note_name="$(echo "$note_json" | jq -r '.name')"
    local note_content
    note_content="$(echo "$note_json" | jq -r '.notes')"

    if [[ -z "$note_name" || "$note_name" == "null" ]]; then
        logger::warn "Could not extract note name from latest note"
        return 4
    fi

    # Return the note name
    echo "$note_name"
}
