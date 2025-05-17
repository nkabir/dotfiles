# gum/log.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::log [--level <level>] [--structured] [--time <layout>] [--format <format>] [message] [key value ...]
# Arguments correspond to "gum log" CLI flags and message.
gum::log() {
    local args=()
    local message=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --level)
                args+=(--level "$2")
                shift 2
                ;;
            --structured|-s)
                args+=(--structured)
                shift
                ;;
            --time)
                args+=(--time "$2")
                shift 2
                ;;
            --format|-t)
                args+=(--format "$2")
                shift 2
                ;;
            --*)
                args+=("$1")
                shift
                ;;
            *)
                # First non-flag argument is the message
                if [[ -z "$message" ]]; then
                    message="$1"
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    # shellcheck disable=SC1091
    . "${GUM_HERE:?}/../logger/core.bash"

    if ! command -v gum >/dev/null 2>&1; then
        logger::error "gum CLI not found in PATH"
        return 2
    fi

    gum log "${args[@]}" "$message"

}
export -f gum::log
