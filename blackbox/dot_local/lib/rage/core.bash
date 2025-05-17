# rage/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_RAGE_CORE" ]] && return 0
_RAGE_CORE=1

RAGE_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Load the rage functions
. "${RAGE_HERE:?}/../logger/core.bash"
. "${RAGE_HERE:?}/encrypt.bash"
