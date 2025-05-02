# bitwarden.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Bitwarden CLI script for Linux

[ -n "$_BITWARDEN_CORE" ] && return 0
_BITWARDEN_CORE=1

# Replace the initial checks with:
if ! command -v bw &> /dev/null; then
    bw_error "BitWarden CLI is not installed" 2
    return 2
fi

BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. ${BITWARDEN_HERE:?}/../logger/core.bash
. ${BITWARDEN_HERE:?}/account.bash
. ${BITWARDEN_HERE:?}/folder.bash
. ${BITWARDEN_HERE:?}/item.bash
. ${BITWARDEN_HERE:?}/note.bash
. ${BITWARDEN_HERE:?}/attachment.bash
