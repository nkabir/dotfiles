# gig/bitwarden/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_BITWARDEN" ]] && return 0
_GIG_BITWARDEN=1

GIG_BITWARDEN_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${GIG_BITWARDEN_HERE:?}/../../lib/logger/core.bash"
. "${GIG_BITWARDEN_HERE}/../../lib/bitwarden/core.bash"
. "${GIG_BITWARDEN_HERE}/../../lib/skate/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::bitwarden::login() {

    if ! skate::set BW_SESSION "$(bw login --raw)" ; then
	logger::error "Failed to login to Bitwarden"
	return 1
    fi
    return 0
}
export -f gig::bitwarden::login
