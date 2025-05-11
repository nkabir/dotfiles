# gpg/restore.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# restore from bitwarden
gpg::restore::bitwarden() {

    local item_id="$1"
    local fingerprint

    # Get item details
    local item_data
    item_data=$(bw get item "$item_id")
    fingerprint=$(echo "$item_data" | jq -r '.name' | cut -d'.' -f1)

    # Download and import keys
    local attachments
    attachments=$(echo "$item_data" | jq -c '.attachments[]')

    echo "$attachments" | while read -r attachment; do
        local attachment_id
        local filename
        attachment_id=$(echo "$attachment" | jq -r '.id')
        filename=$(echo "$attachment" | jq -r '.fileName')

        local temp_file="/tmp/$filename"
        bw get attachment "$attachment_id" --itemid "$item_id" --output "$temp_file"

        # Import the key
        if [[ "$filename" == *"private"* ]]; then
            gpg --import "$temp_file"
        fi

        rm -f "$temp_file"
    done

    # Set trust level
    echo "${fingerprint}:6:" | gpg --import-ownertrust

    echo "$fingerprint"
}
