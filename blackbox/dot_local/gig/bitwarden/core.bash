# gig/bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_BITWARDEN" ]] && return 0
_GIG_BITWARDEN=1

GIG_BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


# shellcheck disable=SC1091
. "${GIG_BITWARDEN_HERE:?}/../../lib/logger/core.bash"
# shellcheck disable=SC1091
. "${GIG_BITWARDEN_HERE}/../../lib/bitwarden/core.bash"
# shellcheck disable=SC1091
. "${GIG_BITWARDEN_HERE}/../../lib/skate/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::login() {

    local session

    if session="$(bitwarden::login --raw)"; then
	logger::info "Login successful!"
	skate::set BW_SESSION "$session"
	return 0
    fi
    return 1
}
export -f gig::bitwarden::login


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::logout() {

    bitwarden::logout
    skate::delete BW_SESSION
}
export -f gig::bitwarden::logout


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::lock() {

    bitwarden::lock
    skate::delete BW_SESSION
}
export -f gig::bitwarden::lock


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::unlock() {

    local session

    if session="$(bitwarden::unlock --raw)"; then
	logger::info "Unlock successful. BW_SESSION initialized."
	skate::set BW_SESSION "$session"
	return 0
    fi
    return 1
}
export -f gig::bitwarden::unlock


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::status() {

    gum spin --title "Querying Bitwarden login status..." \
	--show-output -- bash -c bitwarden::status
}
export -f gig::bitwarden::status


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::sync() {

    gum spin --title "Syncing Bitwarden vault..." \
	--show-output -- bash -c bitwarden::sync
}
export -f gig::bitwarden::sync



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::create-folder() {

    local folder_name="$1"
    if [[ -z "$folder_name" ]]; then
        logger::error "bitwarden::create-folder: Folder name required"
        return 2
    fi

    # Check if the folder already exists
    if bitwarden::get-folder "$folder_name"; then
	logger::error "bitwarden::create-folder: Folder '$folder_name' already exists"
	return 1
    fi

    # Build the encoded JSON for the folder
    local encoded_json
    encoded_json=$(jq -nc --arg name "$folder_name" '{name: $name}' | bw encode)
    if [[ -z "$encoded_json" ]]; then
        logger::error "bitwarden::create-folder: Failed to encode folder JSON"
        return 3
    fi

    # Create the folder
    if bitwarden::create folder "$encoded_json"; then
        logger::info "Folder '$folder_name' created successfully"
        return 0
    else
        logger::error "bitwarden::create-folder: Failed to create folder '$folder_name'"
        return 4
    fi

}
export -f gig::bitwarden::create-folder


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::sync-ssh-keys() {

    local ssh_keys_json
    local ssh_keys
    # get list of SSH key names from Bitwarden
    if ! ssh_keys_json="$(bitwarden::list items --search "ssh.key.ed25519")"; then
        logger::error "Failed to list SSH keys from Bitwarden"
        return 2
    fi
    ssh_keys="$(jq -r '.[] | .name' <<<"$ssh_keys_json")"

    if [[ -z "$ssh_keys" ]]; then
        logger::error "No SSH keys found in Bitwarden"
        return 1
    fi

    # Loop through each SSH key and sync it
    while IFS= read -r key_name; do
        gig::bitwarden::sync-ssh-key "$key_name"
    done <<< "$ssh_keys"

    return 0

}
export -f gig::bitwarden::sync-ssh-keys


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::sync-ssh-key() {

    local key_name="${1:?"Key name required"}"
    local ssh_dir="$HOME/.ssh"
    local key_path=""
    local tmp_file=""
    local item_json=""
    local private_key=""

    if [[ ! "$key_name" =~ ^[A-Za-z0-9._-]+$ ]]; then
        logger::error "Invalid SSH key name: $key_name"
        return 2
    fi
    key_path="${ssh_dir}/${key_name}"
    mkdir -p "$ssh_dir"

    if ! item_json="$(bitwarden::get item "$key_name")"; then
        logger::error "Failed to fetch SSH key $key_name from Bitwarden"
        return 3
    fi
    if ! private_key="$(jq -e -r '.sshKey.privateKey | select(type=="string" and length>0)' <<<"$item_json")"; then
        logger::error "Missing SSH private key data for $key_name"
        return 4
    fi

    if ! tmp_file="$(mktemp "${key_path}.XXXXXX")"; then
        logger::error "Failed to create temp file for $key_name"
        return 5
    fi

    printf '%s\n' "$private_key" > "$tmp_file"
    mv -f "$tmp_file" "$key_path"
    chmod 600 "$key_path"

    # if key_name ends with main, then symlink it to id_ed25519
    if [[ "$key_name" == *main ]]; then
        ln -sf "$key_path" "$ssh_dir/id_ed25519"
        chmod 600 "$HOME/.ssh/id_ed25519"
        logger::info "SSH key synced to $key_path"
        logger::info "SSH key synced and symlinked to id_ed25519"
    else
        logger::info "SSH key synced to $key_path"
    fi

    return 0
}
export -f gig::bitwarden::sync-ssh-key
