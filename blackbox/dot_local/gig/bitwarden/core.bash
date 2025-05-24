# gig/bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_BITWARDEN" ]] && return 0
_GIG_BITWARDEN=1

GIG_BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${GIG_BITWARDEN_HERE:?}/../../lib/logger/core.bash"
. "${GIG_BITWARDEN_HERE}/../../lib/bitwarden/core.bash"
. "${GIG_BITWARDEN_HERE}/../../lib/skate/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::login() {

    local session

    session="$(bitwarden::login --raw)"

    # Check if the login was successful
    if [[ $? -eq 0 ]]; then
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

    session="$(bitwarden::unlock --raw)"

    # Check if the unlock was successful
    if [[ $? -eq 0 ]]; then
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

    local ssh_key_path="$HOME/.ssh/id_rsa"
    local ssh_pub_key_path="$HOME/.ssh/id_rsa.pub"

    # Check if the SSH key files exist
    if [[ ! -f "$ssh_key_path" || ! -f "$ssh_pub_key_path" ]]; then
        logger::error "SSH key files not found at $ssh_key_path or $ssh_pub_key_path"
        return 1
    fi

    # Sync the SSH keys to Bitwarden
    bitwarden::sync-ssh-keys "$ssh_key_path" "$ssh_pub_key_path"
}
export -f gig::bitwarden::sync-ssh-keys


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::sync-ssh-key() {

    local key_name="${1:?"Key name required"}"


    bitwarden::get item "$key_name" \
        | jq -r .sshKey.privateKey > "$HOME/.ssh/$key_name"

    # if key_name ends with main, then symlink it to id_ed25519
    if [[ "$key_name" == *main ]]; then
        ln -sf "$HOME/.ssh/$key_name" "$HOME/.ssh/id_ed25519"
        chmod 600 "$HOME/.ssh/id_ed25519"
        logger::info "SSH key synced and symlinked to id_ed25519"
    else
        logger::info "SSH key synced"
    fi
    chmod 600 "$HOME/.ssh/$key_name"

    return 0
}
export -f gig::bitwarden::sync-ssh-key
