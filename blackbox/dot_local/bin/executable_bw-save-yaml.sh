#!/usr/bin/env bash
# This script is used to update a Bitwarden item with a YAML file.
# Check if the user is logged in to Bitwarden
if ! bw status | grep -q "Logged in"; then
    echo "You are not logged in to Bitwarden. Please log in first."
    exit 1
fi

# 1. Get the item ID from the command line argument
# 2. Get the YAML file from the command line argument
# 3. Read the YAML file and convert it to JSON
# Check if the user provided a YAML file and an item ID
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <yaml_file> <item_id>"
    exit 1
fi

# Get the YAML file and item ID from the command line arguments
YAML_FILE="${1:?Missing YAML file}"
ITEM_ID="${2:?Missing item ID}"

# Check if the YAML file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "YAML file not found: $YAML_FILE"
    exit 1
fi

# Check if the YAML file is valid
if ! cat "$YAML_DOC" | yq eval '.' - > /dev/null 2>&1; then
    echo "Invalid YAML document"
    exit 1
fi

# Read the modified YAML back and embed it into the item JSON Note:
#    This assumes a simple case. More complex JSON structures might
#    require adjusting the jq command to preserve other fields if
#    necessary.

cat ${YAML_FILE:?} | jq -sl '.' - ${YAML_FILE:?}.json | jq '.[0] | .notes = .[1]' ${YAML_FILE:?}.json > ${YAML_FILE:?}.updated.json

# 4. Encode the modified JSON
ENCODED_JSON=$(cat ${YAML_FILE:?}.updated.json | bw encode)

# 5. Write the changes back to Bitwarden
bw edit item "${ITEM_ID:?}" ${ENCODED_JSON:?}"

# Clean up temporary files
rm ${YAML_FILE:?}.json ${YAML_FILE:?}.updated.json
