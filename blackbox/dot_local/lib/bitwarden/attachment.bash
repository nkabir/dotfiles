# bitwarden/attachment.bash
# Bitwarden CLI script to upload and download attachments
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_ATTACHMENT" ] && return 0
_BITWARDEN_ATTACHMENT=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::attachment::list() {
    local note_name="$1"
    if [[ -z "$note_name" ]]; then
        logger::error "Usage: bitwarden::attachment::list-by-note-name <note_name>"
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
bitwarden::attachment::id() {
    local note_name="$1"
    local attachment_name="$2"

    if [[ -z "$note_name" || -z "$attachment_name" ]]; then
        logger::error "Usage: bitwarden::attachment::id <note_name> <attachment_name>"
        return 1
    fi

    # Get the item ID for the note
    local item_id
    item_id="$(bitwarden::item::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::debug "Note '$note_name' not found."
        return 0
    fi

    # Get the attachment ID by filtering attachments array for matching filename
    local attachment_id
    attachment_id="$(bw get item "$item_id" | jq -r --arg fname "$attachment_name" '.attachments[]? | select(.fileName == $fname) | .id')"

    # If empty, return nothing
    if [[ -n "$attachment_id" ]]; then
        echo "$attachment_id"
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::attachment::create() {
    local note_name="$1"
    local attachment_path="$2"

    if [[ -z "$note_name" || -z "$attachment_path" ]]; then
        logger::error "Usage: bitwarden::note::upload-attachment <note_name> <attachment_path>"
        return 1
    fi

    if [[ ! -f "$attachment_path" ]]; then
        logger::error "Attachment file '$attachment_path' does not exist."
        return 2
    fi

    # Get the item ID for the note
    local item_id
    item_id="$(bitwarden::note::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::error "Note named '$note_name' not found."
        return 4
    fi

    # Upload the attachment
    local result
    result="$(bw create attachment --itemid "$item_id" --file "$attachment_path" 2>&1)"
    if [[ $? -eq 0 ]]; then
        logger::info "Successfully uploaded attachment '$attachment_path' to note '$note_name'"
        return 0
    else
        logger::error "Failed to upload attachment: $result"
        return 5
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::attachment::delete() {
    local note_name="$1"
    local attachment_name="$2"

    if [[ -z "$note_name" || -z "$attachment_name" ]]; then
        logger::error "Usage: bitwarden::note::delete-attachment <note_name> <attachment_name>"
        return 1
    fi

    # Get the item ID by note name
    local item_id
    item_id="$(bitwarden::note::id "$note_name")"
    if [[ -z "$item_id" ]]; then
        logger::warn "Note named '$note_name' not found."
        return 0
    fi

    # List attachments for the item and find the attachment ID by name
    local attachment_id
    attachment_id=$(bitwarden::attachment::id "$note_name" "$attachment_name")

    if [[ -z "$attachment_id" ]]; then
        logger::info "Attachment '$attachment_name' not found on note '$note_name'. Nothing to delete."
        return 0
    fi

    # Delete the attachment by ID
    local result
    result="$(bw delete attachment "$attachment_id" --itemid "$item_id" 2>&1)"
    if [[ $? -eq 0 ]]; then
        logger::info "Successfully deleted attachment '$attachment_name' from note '$note_name' (attachment id: $attachment_id)"
        return 0
    else
        logger::error "Failed to delete attachment '$attachment_name' from note '$note_name': $result"
        return 2
    fi
}
