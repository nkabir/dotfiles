# bitwarden.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Bitwarden CLI script for Linux

[ -n "$_BITWARDEN_CORE" ] && return 0
_BITWARDEN_CORE=1

# Replace the initial checks with:
if ! command -v bw &> /dev/null; then
    bw_error "BitWarden CLI is not installed" 2
    return 2
fi

BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. ${BITWARDEN_HERE:?}/../logger/core.bash
. ${BITWARDEN_HERE:?}/account.bash
. ${BITWARDEN_HERE:?}/folder.bash
. ${BITWARDEN_HERE:?}/item.bash


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
