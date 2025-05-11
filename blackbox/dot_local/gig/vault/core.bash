# gig/vault/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "${_VAULT_CORE:-}" ] && return 0
_VAULT_CORE=1

VAULT_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${VAULT_HERE:?}/../../lib/bitwarden/core.bash"


REMOTE_FOLDER="gig.vault"
SECRET_GIT="secrets.github.com"
LOCAL_FOLDER="$HOME/.config/${REMOTE_FOLDER:?}"
KEY_NAME="${REMOTE_FOLDER:?}@${SECRET_GIT:?}"
PUBLIC_ATTACHMENT="public.asc"
PRIVATE_ATTACHMENT="private.asc"
# NOTE_NAME=<fp-16>.secrets.github.com

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::init() {

    mkdir -p "$LOCAL_FOLDER"
    bitwarden::folder::create "${REMOTE_FOLDER:?}"

}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
vault::backup() {


    local note_name="${1:-$NOTE_NAME}"
    local remote_folder="${1:-$REMOTE_FOLDER}"

    # check if $NOTE_NAME secure note exists in Bitwarden
    if ! bitwarden::note::id "${note_name:?}"; then
	echo "Note ${note_name:?} does not exist in Bitwarden"
    fi



    return 0
}
