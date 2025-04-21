#!/usr/bin/env bash
# bw-get-file.sh
# get file from bitwarden attachment

# Usage: ./bw-get-file.sh <item_id> <attachment_filename> <output_directory>

readonly ITEM_NAME="${1:?Missing ITEM_NAME}"
readonly ATTACHMENT_FILENAME="${2:?Missing ATTACHMENT_FILENAME}"

# Default output directory is current directory if not provided
# If you want to specify a different directory, pass it as the third argument
# Example: ./bw_download_attachment.sh <item_id> <attachment_filename> /path/to/output
# If no output directory is provided, use the current directory
OUTPUT_DIR="${3:-./${ATTACHMENT_FILENAME:?}}"

if [[ -z "$ITEM_NAME" || -z "$ATTACHMENT_FILENAME" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <item_id> <attachment_filename> <output_directory>"
    exit 1
fi

# Ensure Bitwarden session is unlocked
if [[ -z "$BW_SESSION" ]]; then
    echo "Please unlock your Bitwarden vault and export BW_SESSION."
    exit 1
fi

# Download the attachment
bw get attachment "$ATTACHMENT_FILENAME" --itemid "$ITEM_NAME" --output "$OUTPUT_DIR" --session "$BW_SESSION"

if [[ $? -eq 0 ]]; then
    echo "Attachment downloaded successfully to $OUTPUT_DIR"
else
    echo "Failed to download attachment."
    exit 1
fi
