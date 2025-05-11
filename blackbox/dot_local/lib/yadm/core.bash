# yadm/core.bash
#
# YADM - Yet Another Dotfiles Manager
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_YADM_CORE" ] && return 0
_YADM_CORE=1

YADM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
export YADM_GPG_EMAIL="yadm@secrets.github.com"
export YADM_GPG_NAME="YADM Secrets"


. "${YADM_HERE:?}/../logger/core.bash"
. "${YADM_HERE:?}/bitwarden.bash"
. "${YADM_HERE:?}/gpg.bash"



# yadm::init
# ---
# yadm::bitwarden::init
# yadm::gpg::init

# yadm::restore
# ---
# yadm::bitwarden::restore # download secrets from bitwarden
#  bitwarden::
# yadm::gpg::restore # loads secrets into gpg

# yadm::backup
# ---
# yadm::gpg::backup # writes secrets to asc files
#  yadm-secrets.github.com.private.asc
#  yadm-secrets.github.com.public.asc
#  yadm-secrets.github.com.revoke.asc
# yadm::bitwarden::backup # uploads secrets to bitwarden

# yadm::clean
# ---
# delete local gpg keypair

# yadm::encrypt
# ---

# yadm::decrypt
# ---


# yadm::init
#   yadm::bitwarden::init
#     bitwarden::folder::init "yadm"
#     note_name = bitwarden::note::latest # get latest note name
#     bitwarden::attachment::download note_name public.asc ./public.asc
#     bitwarden::attachment::download note_name private.asc ./private.asc
#   yadm::gpg::init
#     if public.asc and private.asc are available, load them
#     otherwise no backup exists. Force user to create new key pair
#   yadm::gpg::backup
#     gpg::primary::export
