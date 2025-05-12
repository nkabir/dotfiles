# item.bash
#
# In the context of the Bitwarden Command Line Interface (CLI), an
# "item" refers to any single record or piece of data stored within
# your Bitwarden vault.
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# return an id for a named item
bitwarden::item::id() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        logger::error "Usage: bitwarden::item::id <search_term>"
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
