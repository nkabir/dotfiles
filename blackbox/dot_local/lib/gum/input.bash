# gum/inpput.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::input [--placeholder <text>] [--password] [--value <default>] [--width <cols>] [--prompt.<style>=<value> ...]
# Arguments correspond to "gum input" CLI flags.
gum::input() {
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --placeholder)
                args+=(--placeholder "$2")
                shift 2
                ;;
            --password)
                args+=(--password)
                shift
                ;;
            --value)
                args+=(--value "$2")
                shift 2
                ;;
            --width)
                args+=(--width "$2")
                shift 2
                ;;
            --prompt.*|--cursor.*|--header.*|--width.*)
                # Pass all style flags through
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Any non-flag argument is ignored (gum input does not take positional args)
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

    gum input "${args[@]}"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::info "gum input completed"
    else
        logger::warn "gum input failed or was cancelled"
    fi
    return $status
}
export -f gum::input
