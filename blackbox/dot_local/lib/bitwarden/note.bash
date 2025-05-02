# bitwarden/note.bash
# This script is used to create a note in Bitwarden
# It requires the Bitwarden CLI to be installed and configured.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_NOTE" ] && return 0
_BITWARDEN_NOTE=1


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
