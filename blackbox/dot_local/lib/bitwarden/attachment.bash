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
