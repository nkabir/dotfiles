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


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bitwarden::list
# Usage:
#   bitwarden::list <object> [--url <url>] [--folderid <id>] [--collectionid <id>] [--organizationid <id>] [--trash] [--search <term>]
bitwarden::list() {
    local object=""
    local url=""
    local folderid=""
    local collectionid=""
    local organizationid=""
    local trash=""
    local search=""
    local args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            items|folders|collections|organizations|org-collections|org-members)
                if [[ -n "$object" ]]; then
                    logger::error "Multiple objects specified: $object and $1"
                    return 1
                fi
                object="$1"
                shift
                ;;
            --url)
                url="$2"
                shift 2
                ;;
            --folderid)
                folderid="$2"
                shift 2
                ;;
            --collectionid)
                collectionid="$2"
                shift 2
                ;;
            --organizationid)
                organizationid="$2"
                shift 2
                ;;
            --trash)
                trash="--trash"
                shift
                ;;
            --search)
                search="$2"
                shift 2
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

    if [[ -z "$object" ]]; then
        logger::error "No object specified for bitwarden::list"
        return 2
    fi

    [[ -n "$url" ]] && args+=(--url "$url")
    [[ -n "$folderid" ]] && args+=(--folderid "$folderid")
    [[ -n "$collectionid" ]] && args+=(--collectionid "$collectionid")
    [[ -n "$organizationid" ]] && args+=(--organizationid "$organizationid")
    [[ -n "$trash" ]] && args+=("$trash")
    [[ -n "$search" ]] && args+=(--search "$search")

    logger::info "Listing Bitwarden $object: ${args[*]}"
    bw list "$object" "${args[@]}"
}
export -f bitwarden::list


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bitwarden::get
# Usage:
#   bitwarden::get <object> <id_or_search> [options]
#   bitwarden::get attachment <filename> --itemid <id> [--output <path>]
#   bitwarden::get notes <id_or_search>
#   bitwarden::get template <object>
bitwarden::get() {
    local object=""
    local id_or_search=""
    local filename=""
    local itemid=""
    local output=""
    local args=()
    local mode=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            attachment)
                object="attachment"
                mode="attachment"
                shift
                if [[ $# -gt 0 ]]; then
                    filename="$1"
                    shift
                fi
                ;;
            notes)
                object="notes"
                mode="notes"
                shift
                if [[ $# -gt 0 ]]; then
                    id_or_search="$1"
                    shift
                fi
                ;;
            template)
                object="template"
                mode="template"
                shift
                if [[ $# -gt 0 ]]; then
                    id_or_search="$1"
                    shift
                fi
                ;;
            --itemid)
                itemid="$2"
                shift 2
                ;;
            --output)
                output="$2"
                shift 2
                ;;
            -*)
                args+=("$1")
                shift
                ;;
            *)
                if [[ -z "$object" ]]; then
                    object="$1"
                    shift
                    if [[ $# -gt 0 ]]; then
                        id_or_search="$1"
                        shift
                    fi
                else
                    args+=("$1")
                    shift
                fi
                ;;
        esac
    done

    logger::info "bitwarden::get: object=$object id_or_search=$id_or_search filename=$filename itemid=$itemid output=$output args=${args[*]}"

    if [[ "$mode" == "attachment" ]]; then
        if [[ -z "$filename" || -z "$itemid" ]]; then
            logger::error "bitwarden::get: attachment requires <filename> and --itemid <id>"
            return 2
        fi
        local cmd=(bw get attachment "$filename" --itemid "$itemid")
        [[ -n "$output" ]] && cmd+=(--output "$output")
        "${cmd[@]}"
        return $?
    elif [[ "$mode" == "notes" ]]; then
        if [[ -z "$id_or_search" ]]; then
            logger::error "bitwarden::get: notes requires <id_or_search>"
            return 2
        fi
        bw get notes "$id_or_search" "${args[@]}"
        return $?
    elif [[ "$mode" == "template" ]]; then
        if [[ -z "$id_or_search" ]]; then
            logger::error "bitwarden::get: template requires <object>"
            return 2
        fi
        bw get template "$id_or_search" "${args[@]}"
        return $?
    else
        if [[ -z "$object" || -z "$id_or_search" ]]; then
            logger::error "bitwarden::get: requires <object> <id_or_search>"
            return 2
        fi
        bw get "$object" "$id_or_search" "${args[@]}"
        return $?
    fi
}
export -f bitwarden::get
