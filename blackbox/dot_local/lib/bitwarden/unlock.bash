# bitwarden/unlock.bash
# shellcheck shell=bash
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
        if session=$(bw unlock "${args[@]}" 2>/dev/null); then
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
