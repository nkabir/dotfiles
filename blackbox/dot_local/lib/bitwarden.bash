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
bitwarden::get-folder-id() {
    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "Usage: bitwarden::get-folder-id-by-name <folder_name>"
        return 1
    fi

    local folder_id
    folder_id="$(bw list folders | jq -r --arg name "$folder_name" '.[] | select(.name == $name) | .id')"

    if [[ -n "$folder_id" ]]; then
        echo "$folder_id"
        return 0
    else
        logger::warn "No folder found with name '$folder_name'"
        return 1
    fi
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::item-exists() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        logger::error "Usage: bitwarden::item-exists <search_term>"
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
