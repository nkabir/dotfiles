# gig/vault/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "${_VAULT_CORE:-}" ] && return 0
_VAULT_CORE=1

VAULT_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${VAULT_HERE:?}/../../lib/cmd/core.bash"
. "${VAULT_HERE:?}/../../lib/bitwarden/core.bash"


REQUIRED_TOOLS=(
    yadm
    gpg
    bw
    git
    jq
)

REMOTE_FOLDER="gig.vault"
SECRET_GIT="secrets.github.com"
LOCAL_FOLDER="$HOME/.config/${REMOTE_FOLDER:?}"
KEY_NAME="${REMOTE_FOLDER:?}@${SECRET_GIT:?}"
PUBLIC_ATTACHMENT="public.asc"
PRIVATE_ATTACHMENT="private.asc"
# NOTE_NAME=<fp-16>.secrets.github.com


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::cmd::check() {

    local missing_tools=()
    local required_tools=("${REQUIRED_TOOLS[@]}")

    for tool in "${required_tools[@]}"; do
        if ! cmd::check "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi

    return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::state() {

    local state_file="/tmp/gig-vault-state.json"

    # Initialize state object
    echo '{"bitwarden_items":[],"git_repos":[],"local_gpg_keys":[]}' > "$state_file"

    # Check Bitwarden for vault items
    local folder_id
    folder_id=$(bitwarden::folder::id "$REMOTE_FOLDER")

    if [ -n "$folder_id" ]; then
        local items
        items=$(bw list items --folderid "$folder_id" | jq -c '[.[] | select(.type == 2 and .name | endswith(".github.com"))]')
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
