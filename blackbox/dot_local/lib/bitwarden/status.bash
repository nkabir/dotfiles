# bitwarden/status.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


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
    if ! status_json="$(bw status 2>/dev/null)"; then
        logger::error "Failed to get Bitwarden status"
        return 2
    fi

    if [[ $raw_output -eq 1 ]]; then
        echo "$status_json"
    else
        jq . <<< "$status_json"
    fi
}
export -f bitwarden::status
