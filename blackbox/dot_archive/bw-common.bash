# bw-common.bash

# Function to display error messages and return error code
bw_error() {
    local message="$1"
    local exit_code="${2:-1}"
    echo "Error: $message" >&2
    return "$exit_code"
}

# Add after the bw_error function:
# Function to check if BitWarden is unlocked
is_bw_unlocked() {
    local status=$(bw status | jq -r '.status')
    if [ "$status" != "unlocked" ]; then
        bw_error "BitWarden is locked. Please login using 'bw login' or unlock with 'bw unlock'" 3
        return 1
    fi
    return 0
}

# Add after the ensure_bw_folder function:
# Function to get folder ID by name
get_bw_folder_id() {
    local folder_name="$1"

    if [ -z "$folder_name" ]; then
        bw_error "Folder name is required"
        return 1
    fi

    local folder_id=$(bw list folders | jq -r ".[] | select(.name==\"$folder_name\") | .id")

    if [[ -z "$folder_id" ]]; then
        bw_error "Folder '$folder_name' not found"
        return 1
    fi

    echo "$folder_id"
    return 0
}

# Add after the get_bw_folder_id function:
# Function to check if an item exists by name
bw_item_exists() {
    local item_name="$1"

    if [ -z "$item_name" ]; then
        bw_error "Item name is required"
        return 1
    fi

    local item_id=$(bw list items --search "$item_name" | jq -r '.[] | select(.name=="'"$item_name"'") | .id')

    if [ -z "$item_id" ] || [ "$item_id" == "null" ]; then
        return 1
    fi

    echo "$item_id"
    return 0
}

# Replace the initial checks with:
if ! command -v bw &> /dev/null; then
    bw_error "BitWarden CLI is not installed" 2
    return 2
fi

# Check if user is logged in
is_bw_unlocked || return $?

bw sync

# Modify ensure_bw_folder function:
ensure_bw_folder() {
    local folder_name="$1"

    # Check if folder_name is provided
    if [ -z "$folder_name" ]; then
        bw_error "Folder name is required"
        return 1
    fi

    # Get list of folders
    local folders=$(bw list folders)

    # Check if folder already exists
    if echo "$folders" | jq -e ".[] | select(.name == \"$folder_name\")" &> /dev/null; then
        echo "Folder '$folder_name' already exists in BitWarden"
        return 0
    fi

    # Create the folder
    echo "Creating folder '$folder_name' in BitWarden..."
    bw create folder --name "$folder_name"

    if [ $? -eq 0 ]; then
        echo "Folder '$folder_name' created successfully"
        return 0
    else
        bw_error "Failed to create folder '$folder_name'" 4
        return 4
    fi
}

# Modify ensure_bw_note function:
ensure_bw_note() {
    # Parameters
    local item_name="$1"
    local folder_name="$2"
    local comment="$3"

    # Check if parameters are provided
    if [[ -z "$item_name" || -z "$folder_name" || -z "$comment" ]]; then
        bw_error "Missing parameters. Usage: create_secure_note item_name folder_name comment"
        return 1
    fi

    # Get folder ID
    local folder_id=$(get_bw_folder_id "$folder_name")
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Check if item already exists
    local item_id=$(bw_item_exists "$item_name")
    if [ $? -eq 0 ]; then
        echo "SecureNote '$item_name' already exists. Doing nothing."
        return 0
    fi

    # Create SecureNote JSON template
    local note_json=$(cat <<EOF
{
  "type": 2,
  "name": "$item_name",
  "notes": "$comment",
  "folderId": "$folder_id",
  "secureNote": {
    "type": 0
  }
}
EOF
)

    # Create the SecureNote
    echo $note_json | bw encode | bw create item

    if [[ $? -eq 0 ]]; then
        echo "SecureNote '$item_name' created successfully in folder '$folder_name'"
        return 0
    else
        bw_error "Failed to create SecureNote"
        return 1
    fi
}

# Modify bw_download_attachment function:
function bw_download_attachment() {
    # Parameters
    local item_name="$1"
    local attachment_name="$2"
    local output_path="$3"

    # Ensure BitWarden is unlocked
    is_bw_unlocked || return $?

    # Get the item ID from the item name
    local item_id=$(bw_item_exists "$item_name")
    # Check if item exists
    if [ $? -ne 0 ]; then
        return 0
    fi

    # Get the attachment ID for the given attachment name
    local attachment_id=""
    local secure_note=$(bw get item "$item_id")

    # Check if there is an attachments key in the JSON
    if echo "$secure_note" | jq -e 'has("attachments")' &> /dev/null; then
        attachment_id=$(echo "$secure_note" | jq -r ".attachments[] | select(.fileName==\"$attachment_name\") | .id")
    fi

    # Check if attachment exists
    if [ -z "$attachment_id" ] || [ "$attachment_id" == "null" ]; then
        return 0
    fi

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output_path")"

    # Download the attachment
    bw get attachment "$attachment_id" --itemid "$item_id" --output "$output_path" > /dev/null 2>&1

    # Check if download was successful
    if [ $? -eq 0 ]; then
        echo "$output_path"
    fi
}


# Modify bw_gpg_upload function:
function bw_gpg_upload() {
    # Check if we have 2 arguments
    if [ $# -ne 2 ]; then
        bw_error "Usage: bw_gpg_upload <folder_name> <note_name>"
        return 1
    fi

    local folder_name="$1"
    local note_name="$2"
    local key_name="yadm-bw"
    local temp_dir=$(mktemp -d)
    local key_file="${temp_dir}/yadm-bw-key.asc"

    echo "Creating GPG key for '$key_name'..."

    # Generate batch file for unattended key generation
    cat > "${temp_dir}/gpg-batch" << EOF
%echo Generating a GPG key
Key-Type: RSA
Key-Length: 4096
Name-Real: $key_name
Name-Email: $key_name@localhost
Expire-Date: 0
%no-protection
%commit
%echo Key generation completed
EOF

    # Generate the key
    gpg --batch --generate-key "${temp_dir}/gpg-batch"
    if [ $? -ne 0 ]; then
        bw_error "Failed to generate GPG key" 2
        rm -rf "$temp_dir"
        return 2
    fi

    # Get the key fingerprint
    local fingerprint=$(gpg --list-keys --with-colons "$key_name" | grep "^fpr" | head -n1 | cut -d: -f10)

    # Export the key with ASCII armor
    gpg --armor --export "$fingerprint" > "$key_file"
    if [ $? -ne 0 ] || [ ! -s "$key_file" ]; then
        bw_error "Failed to export GPG key" 3
        rm -rf "$temp_dir"
        return 3
    fi

    echo "GPG key exported to $key_file"

    # Check if BitWarden is unlocked
    is_bw_unlocked || { rm -rf "$temp_dir"; return $?; }

    # Get folder ID
    local folder_id=$(get_bw_folder_id "$folder_name")
    if [ $? -ne 0 ]; then
        rm -rf "$temp_dir"
        return 5
    fi

    # Check if note exists and get its ID, otherwise create it
    local note_id=$(bw_item_exists "$note_name")
    local note_exists=$?

    if [ $note_exists -ne 0 ]; then
        echo "Creating new secure note '$note_name' in folder '$folder_name'..."

        # Create JSON for the new note
        local note_json=$(cat << EOF
{
  "type": 2,
  "name": "$note_name",
  "notes": "GPG key for yadm-bw",
  "folderId": "$folder_id",
  "secureNote": {
    "type": 0
  }
}
EOF
)

        # Create the note
        local result=$(echo "$note_json" | bw create item)
        note_id=$(echo "$result" | jq -r '.id')

        if [ -z "$note_id" ] || [ "$note_id" == "null" ]; then
            bw_error "Failed to create secure note" 6
            rm -rf "$temp_dir"
            return 6
        fi
    fi

    # Upload the key file as an attachment
    echo "Uploading key as attachment to note '$note_name'..."
    bw create attachment --file "$key_file" --itemid "$note_id"

    if [ $? -ne 0 ]; then
        bw_error "Failed to upload attachment" 7
        rm -rf "$temp_dir"
        return 7
    fi

    echo "Success! GPG key uploaded to BitWarden note '$note_name' in folder '$folder_name'"

    # Clean up
    rm -rf "$temp_dir"
    return 0
}
