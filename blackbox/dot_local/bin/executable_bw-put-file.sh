#!/usr/bin/env bash

# --- Configuration ---
readonly YAML_FILE="${1:?Missing YAML file}"
readonly ITEM_ID="${2:?Missing BitWarden item identifier}"

if [[ -z "$ITEM_ID" || -z "$YAML_FILE" ]]; then
    echo "Usage: $0 <item-id> <yaml-file>"
    exit 1
fi

if [[ ! -f "$YAML_FILE" ]]; then
    echo "YAML file not found: $YAML_FILE"
    exit 1
fi

# Read YAML file contents
YAML_CONTENT=$(<"$YAML_FILE")

# Escape newlines for JSON
YAML_CONTENT_ESCAPED=$(printf '%s' "$YAML_CONTENT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')

PAYLOAD="$(bw get item "$ITEM_ID")"

# extract "id" from PAYLOAD with jq
ITEM_GUID=$(echo "$PAYLOAD" | jq -r '.id')


# Retrieve the item, update notes, encode, and edit
# bw get item "$ITEM_ID" \
echo $PAYLOAD \
    | jq --arg note "$YAML_CONTENT_ESCAPED" '.notes = $note' \
    | bw encode \
    | bw edit item "$ITEM_GUID"

bw sync
