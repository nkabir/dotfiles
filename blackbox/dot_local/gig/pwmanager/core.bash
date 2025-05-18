# gig/pwmanager/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_GIG_PWMANAGER" ]] && return 0
_GIG_PWMANAGER=1

GIG_PWMANAGER_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${GIG_PWMANAGER_HERE:?}/../../lib/logger/core.bash"
. "${PWMANAGER_HERE}/../../lib/bitwarden/core.bash"
. "${PWMANAGER_HERE}/../../lib/skate/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gig::pwmanager::login() {

    if ! skate::set BW_SESSION "$(bw login --raw)" ; then
	logger::error "Failed to login to Bitwarden"
	return 1
    fi

}
export -f gig::pwmanager::login
