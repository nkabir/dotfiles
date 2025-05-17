# bitwarden/login.bash

bitwarden::login::client-id() {

    local client_id="${1}"
    if [[ -z "${client_id}" ]]; then
	client_id="$(skate get "bitwarden/client_id")"
	if [[ -z "${client_id}" ]]; then
	    echo "No client ID found. Please set it using skate."
	    return 1
	fi
    elif [[ "${client_id}" == "none" ]]; then
	if ! skate set "bitwarden/client_id" "${client_id}"; then
	    echo "Failed to set client ID."
	    return 1
	fi
    fi
}
