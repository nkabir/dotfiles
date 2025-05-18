# gig/pwmanager/login.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
PWMANAGER_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


. "${PWMANAGER_HERE}/../../lib/bitwarden/core.bash"
. "${PWMANAGER_HERE}/../../lib/skate/core.bash"

gig::pwmanager::login() {

    if ! skate::set BW_SESSION "$(bw login --raw)" ; then
	logger::error "Failed to login to Bitwarden"
	return 1
    fi

}
export -f gig::pwmanager::login
