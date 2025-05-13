# gig/vault/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "${_VAULT_CORE:-}" ] && return 0
_VAULT_CORE=1

VAULT_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${VAULT_HERE:?}/../../lib/cmd/core.bash"
. "${VAULT_HERE:?}/../../lib/bitwarden/core.bash"
. "${VAULT_HERE:?}/../../lib/gpg/core.bash"
. "${VAULT_HERE:?}/../../lib/yadm/core.bash"



REQUIRED_TOOLS=(
    yadm
    gpg
    bw
    git
    jq
)

BITWARDEN_FOLDER="gig.vault"
SECRET_GIT="secrets.github.com"
LOCAL_FOLDER="$HOME/.config/${BITWARDEN_FOLDER:?}"
KEY_UID="yadm@${SECRET_GIT:?}"
PUBLIC_ATTACHMENT="public.asc"
PRIVATE_ATTACHMENT="private.asc"
# NOTE_NAME=<fp-16>.secrets.github.com



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::check() {

    local missing_tools=()
    local required_tools=("${REQUIRED_TOOLS[@]}")

    for tool in "${required_tools[@]}"; do
        if ! cmd::check "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        logger::error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi

    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# backup vault key and content
vault::backup() {

    echo $KEY_UID

    gpg::backup::bitwarden $KEY_UID "$BITWARDEN_FOLDER"
    yadm::repository::sync
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::state() {

    local state_file="/tmp/gig-vault-state.json"

    # Initialize state object
    echo '{"bitwarden_items":[],"git_repos":[],"local_gpg_keys":[]}' > "$state_file"

    # # Check Bitwarden for vault items
    local folder_id
    folder_id=$(bitwarden::folder::id "$BITWARDEN_FOLDER")

    if [ -n "$folder_id" ]; then
        local items
        items=$(bw list items --folderid "$folder_id" | jq -c '[.[] | select(.type == 2)]')
        echo "$(jq --argjson items "$items" '.bitwarden_items = $items' "$state_file")" > "$state_file"
    fi

    # Check local GPG keys
    local gpg_keys
    gpg_keys=$(gpg --list-secret-keys --with-colons | grep '^fpr:' | cut -d':' -f10 | jq -R -s -c 'split("\n") | map(select(length > 0))')
    echo "$(jq --argjson keys "$gpg_keys" '.local_gpg_keys = $keys' "$state_file")" > "$state_file"

    # Check for existing YADM repository
    if yadm status >/dev/null 2>&1; then
        local remote_url
        remote_url=$(yadm remote get-url origin 2>/dev/null || echo "")
        if [ -n "$remote_url" ]; then
            echo "$(jq --arg url "$remote_url" '.git_repos += [$url]' "$state_file")" > "$state_file"
        fi
    fi

    echo "$state_file"

}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# get vault status
vault::status() {

    local state_file
    state_file=$(vault::state)
    cat $state_file
    rm -f "$state_file"
}



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::init() {

    logger::info "gig.vault initialization..."

    # Check for required tools
    vault::check || return 1

    if ! bitwarden::account::is-unlocked; then
	bitwarden::account::unlock
    fi

    # Discover existing state
    logger::info "Discovering existing configuration..."
    local state_file
    state_file=$(vault::state)
    local state
    state=$(cat "$state_file")

    # Check if we have existing configuration
    local bitwarden_count
    bitwarden_count=$(echo "$state" | jq -r '.bitwarden_items | length')

    local git_count
    git_count=$(echo "$state" | jq -r '.git_repos | length')

    if [ "$bitwarden_count" -gt 0 ] || [ "$git_count" -gt 0 ]; then
        logger::warn "Existing configuration found:"

        if [ "$bitwarden_count" -gt 0 ]; then
            echo "Bitwarden backups:"
            echo "$state" | jq -r '.bitwarden_items[].name' | while read -r name; do
                echo "  • $name"
            done
        fi

        if [ "$git_count" -gt 0 ]; then
            echo "Git remotes:"
            echo "$state" | jq -r '.git_repos[]' | while read -r repo; do
                echo "  • $repo"
            done
        fi

        rm -f "$state_file"
    fi
    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::
# synchronize secrets
vault::sync() {

    yadm::repository::sync
}


vault::doctor() {
    local issues=()

    logger::info "Verifying vault integrity..."

    # Check GPG key matches YADM config
    if yadm status >/dev/null 2>&1; then
        local configured_key
        configured_key=$(yadm config yadm.gpg-recipient)

        if [ -n "$configured_key" ]; then
            if ! gpg --list-secret-keys "$configured_key" >/dev/null 2>&1; then
                issues+=("Configured GPG key ${configured_key:0:16} not found in keyring")
            fi
        else
            issues+=("No GPG key configured in YADM")
        fi
    else
        issues+=("YADM not initialized")
    fi

    # Check Bitwarden backup exists
    local state_file
    state_file=$(vault::state)
    local backup_count
    backup_count=$(jq -r '.bitwarden_items | length' "$state_file")

    if [ "$backup_count" -eq 0 ]; then
        issues+=("No Bitwarden backups found")
    fi

    # Test encryption/decryption
    if yadm status >/dev/null 2>&1; then
        local test_file="$HOME/.config/yadm/test-encrypt"
        echo "test content" > "$test_file"

        if ! yadm encrypt >/dev/null 2>&1; then
            issues+=("Encryption test failed")
        elif ! yadm decrypt >/dev/null 2>&1; then
            issues+=("Decryption test failed")
        fi

        rm -f "$test_file"
    fi

    rm -f "$state_file"

    if [ ${#issues[@]} -gt 0 ]; then
        logger::error "Integrity issues found:"
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
        return 1
    else
        logger::info "Vault integrity verified"
        return 0
    fi
}
