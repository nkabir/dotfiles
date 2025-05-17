# bitwarden/login.bash
# shellcheck shell=bash
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
