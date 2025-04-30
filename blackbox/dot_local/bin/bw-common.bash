// entire file content ...
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
... rest of code ...
