# gig/bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_BITWARDEN" ]] && return 0
_GIG_BITWARDEN=1

GIG_BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${GIG_BITWARDEN_HERE}/login.bash"
