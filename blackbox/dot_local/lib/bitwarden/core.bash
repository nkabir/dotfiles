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


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::sync() {

    # Sync the vault with the server
    if bw sync ; then
	logger::info "Bitwarden vault synced successfully."
    else
	logger::error "Failed to sync Bitwarden vault."
    fi

}
export -f bitwarden::sync


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bitwarden::login
# Usage:
#   bitwarden::login [--email <email>] [--password <password>] [--method <method>] [--code <code>] [--apikey] [--sso]
bitwarden::login() {
    local email=""
    local password=""
    local method=""
    local code=""
    local apikey=""
    local sso=""
    local args=()


    while [[ $# -gt 0 ]]; do
        case "$1" in
            --email)
                email="$2"
                shift 2
                ;;
            --password)
                password="$2"
                shift 2
                ;;
            --method)
                method="$2"
                shift 2
                ;;
            --code)
                code="$2"
                shift 2
                ;;
            --apikey)
                apikey="--apikey"
                shift
                ;;
            --sso)
                sso="--sso"
                shift
                ;;
	    --raw)
		raw="--raw"
		shift
		;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                logger::error "Unexpected argument: $1"
                return 1
                ;;
        esac
    done

    # Build the argument list
    [[ -n "$email" ]] && args+=("$email")
    [[ -n "$password" ]] && args+=("$password")
    [[ -n "$method" ]] && args+=("--method" "$method")
    [[ -n "$code" ]] && args+=("--code" "$code")
    [[ -n "$apikey" ]] && args+=("$apikey")
    [[ -n "$sso" ]] && args+=("$sso")
    [[ -n "$raw" ]] && args+=("$raw")


    logger::info "Attempting Bitwarden login..."

    if bw login "${args[@]}"; then
        logger::info "Bitwarden login successful"
        return 0
    else
        logger::error "Bitwarden login failed"
        return 2
    fi
}
export -f bitwarden::login


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
bitwarden::status() {
    # Usage: bitwarden::status [--raw]
    local raw_output=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --raw)
                raw_output=1
                shift
                ;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                logger::error "Unexpected argument: $1"
                return 1
                ;;
        esac
    done

    logger::info "Checking Bitwarden CLI status..."

    local status_json
    if ! status_json="$(bw status)"; then
        logger::error "Failed to get Bitwarden status"
        return 2
    fi
    echo "$status_json"
}
export -f bitwarden::status


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bitwarden::unlock
# Usage:
#   bitwarden::unlock [--password <password>] [--passwordenv <envvar>] [--passwordfile <file>] [--raw]
bitwarden::unlock() {
    local password=""
    local passwordenv=""
    local passwordfile=""
    local raw=0
    local args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --password)
                password="$2"
                shift 2
                ;;
            --passwordenv)
                passwordenv="$2"
                shift 2
                ;;
            --passwordfile)
                passwordfile="$2"
                shift 2
                ;;
            --raw)
                raw=1
                shift
                ;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                logger::error "Unexpected argument: $1"
                return 1
                ;;
        esac
    done


    [[ -n "$passwordenv" ]] && args+=(--passwordenv "$passwordenv")
    [[ -n "$passwordfile" ]] && args+=(--passwordfile "$passwordfile")
    [[ $raw -eq 1 ]] && args+=(--raw)

    logger::info "Unlocking Bitwarden vault..."

    if [[ -n "$password" ]]; then
        if session=$(bw unlock "${args[@]}" "$password" 2>/dev/null); then
            logger::info "Bitwarden vault unlocked"
            [[ $raw -eq 1 ]] && echo "$session"
            return 0
        else
            logger::error "Failed to unlock Bitwarden vault"
            return 2
        fi
    else
        if session=$(bw unlock "${args[@]}"); then
            logger::info "Bitwarden vault unlocked"
            [[ $raw -eq 1 ]] && echo "$session"
            return 0
        else
            logger::error "Failed to unlock Bitwarden vault"
            return 2
        fi
    fi
}
export -f bitwarden::unlock
