# yadm.bash
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
. "${YADM_HERE:?}/../gpg/core.bash"
. "${YADM_HERE:?}/../bitwarden/core.bash"
. "${YADM_HERE:?}/bitwarden.bash"
. "${YADM_HERE:?}/gpg.bash"



# init
# yadm::bitwarden::init
# yadm::gpg::init

# restore
# yadm::bitwarden::restore
# yadm::gpg::restore

# backup
# yadm::gpg::backup
# yadm::bitwarden::backup

# reset
# delete local gpg keypair

# encrypt

# decrypt
