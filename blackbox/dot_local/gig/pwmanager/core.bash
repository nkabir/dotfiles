# gig/pwmanager/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_PWMANAGER" ]] && return 0
_GIG_PWMANAGER=1

GIG_PWMANAGER_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${GIG_PWMANAGER_HERE:?}/../../lib/logger/core.bash"
. "${GIG_PWMANAGER_HERE}/login.bash"
