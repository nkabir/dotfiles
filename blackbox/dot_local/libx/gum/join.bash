# gum/join.bash
# shellcheck shell=bash
# Usage:
# gum::join [--align <left|center|right|top|middle|bottom>] [--horizontal|--vertical] <text...>
# Arguments correspond to "gum join" CLI flags and text arguments.

gum::join() {
    local args=()
    local align=""
    local direction=""
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --align)
                align="$2"
                args+=(--align "$2")
                shift 2
                ;;
            --horizontal|--vertical)
                direction="$1"
                args+=("$1")
                shift
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Text arguments
                break
                ;;
        esac
    done

    # Remaining arguments are text to join
    local text_args=()
    while [[ $# -gt 0 ]]; do
        text_args+=("$1")
        shift
    done

    # Logging
    . "${GUM_HERE:?}/../logger/core.bash"
    if ! command -v gum >/dev/null 2>&1; then
        logger::error "gum CLI not found in PATH"
        return 2
    fi

    # Run gum join with all arguments
    gum join "${args[@]}" "${text_args[@]}"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::debug "gum join succeeded"
    else
        logger::error "gum join failed"
    fi
    return $status
}
export -f gum::join
