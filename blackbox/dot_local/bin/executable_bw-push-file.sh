#!/usr/bin/env bash

# Usage: ./add-or-replace-attachment.sh "<item_name>" "<attachment_filename>" "<new_file_path>"
readonly ITEM_NAME="$1"
readonly ATTACHMENT_FILENAME="$2"

# The new file path should be the full path to the new file you want to upload
# The script will delete the existing attachment with the same filename
# and replace it with the new file.
# if blank, it will use the current directory and the attachment filename
readonly NEW_FILE_PATH="${3:-$(pwd)/$ATTACHMENT_FILENAME}"

if [[ -z "$ITEM_NAME" || -z "$ATTACHMENT_FILENAME" || -z "$NEW_FILE_PATH" ]]; then
    echo "Usage: $0 \"<item_name>\" \"<attachment_filename>\" \"<new_file_path>\""
    exit 1
fi

if [[ -z "$BW_SESSION" ]]; then
    echo "Please unlock your Bitwarden vault and export the BW_SESSION environment variable."
    exit 1
fi

# Get item JSON
ITEM_JSON=$(bw get item "$ITEM_NAME")
if [[ -z "$ITEM_JSON" || "$ITEM_JSON" == "Not found." ]]; then
    echo "Item named '$ITEM_NAME' not found."
    exit 1
fi

ITEM_ID=$(echo "$ITEM_JSON" | jq -r '.id')

# Check for existing attachment
ATTACHMENT_ID=$(echo "$ITEM_JSON" | jq -r --arg name "$ATTACHMENT_FILENAME" '.attachments[] | select(.fileName == $name) | .id')

if [[ -n "$ATTACHMENT_ID" && "$ATTACHMENT_ID" != "null" ]]; then
    echo "Replacing existing attachment..."
    bw delete attachment "$ATTACHMENT_ID" --itemid "$ITEM_ID"
else
    echo "Adding new attachment..."
fi

# Upload new attachment
bw create attachment --file "$NEW_FILE_PATH" --itemid "$ITEM_ID"

echo "Operation completed successfully for '$ITEM_NAME'."
bw sync
