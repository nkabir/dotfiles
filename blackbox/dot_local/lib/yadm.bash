# yadm.bash
# yadm - Yet Another Dotfiles Manager
YADM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. ${YADM_HERE:?}/logger.bash
. ${YADM_HERE:?}/gpg.bash

# YADM_GPG - GPG key to use for encryption
YADM_GPG_EMAIL="yadm@localhost"

# YADM_GPG_ID - GPG key ID to use for encryption
YADM_GPG_ID="$(gpg::get-fingerprint "${YADM_GPG_EMAIL:?}")"
