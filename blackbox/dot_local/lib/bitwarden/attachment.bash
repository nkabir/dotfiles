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
