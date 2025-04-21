#!/usr/bin/env bash
# bw-get-yaml.sh
# get yaml from bitwarden

# Usage: ./bw_download_attachment.sh <item_id> <attachment_filename> <output_directory>

ITEM_ID="$1"
ATTACHMENT_FILENAME="$2"
OUTPUT_DIR="$3:-."

if [[ -z "$ITEM_ID" || -z "$ATTACHMENT_FILENAME" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <item_id> <attachment_filename> <output_directory>"
    exit 1
fi

# Ensure Bitwarden session is unlocked
if [[ -z "$BW_SESSION" ]]; then
    echo "Please unlock your Bitwarden vault and export BW_SESSION."
    exit 1
fi

# Download the attachment
bw get attachment "$ATTACHMENT_FILENAME" --itemid "$ITEM_ID" --output "$OUTPUT_DIR" --session "$BW_SESSION"

if [[ $? -eq 0 ]]; then
    echo "Attachment downloaded successfully to $OUTPUT_DIR"
else
    echo "Failed to download attachment."
    exit 1
fi
