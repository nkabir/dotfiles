# bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_CORE" ] && return 0
_BITWARDEN_CORE=1

BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${BITWARDEN_HERE}/../logger/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::logout() {

    bw logout
}
export -f bitwarden::logout


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::lock() {

    bw lock
}
export -f bitwarden::lock


# :::::::::::::::::::::::::::::::::::::::::::::::::::
. "${BITWARDEN_HERE}/login.bash"
. "${BITWARDEN_HERE}/status.bash"
