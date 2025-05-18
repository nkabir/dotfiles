# gum/filter.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::filter [--placeholder <text>] [--limit <n>|--no-limit] [--height <n>] [--width <n>] [--header <text>] [--indicator <text>] [--selected.<style>=<val> ...] [--unselected.<style>=<val> ...] [--prompt.<style>=<val> ...] [input ...]
# Arguments correspond to "gum filter" CLI flags and input.

gum::filter() {
    local args=()
    local input_from_stdin=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --placeholder)
                args+=(--placeholder "$2")
                shift 2
                ;;
            --limit)
                args+=(--limit "$2")
                shift 2
                ;;
            --no-limit)
                args+=(--no-limit)
                shift
                ;;
            --height)
                args+=(--height "$2")
                shift 2
                ;;
            --width)
                args+=(--width "$2")
                shift
                ;;
            --header)
                args+=(--header "$2")
                shift 2
                ;;
            --indicator)
                args+=(--indicator "$2")
                shift 2
                ;;
            --selected.*|--unselected.*|--prompt.*)
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            -)
                # Explicit stdin indicator
                input_from_stdin=1
                shift
                ;;
            *)
                # Treat as input value (if not reading from stdin)
                args+=("$1")
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

    if [[ $input_from_stdin -eq 1 || ! -t 0 ]]; then
        gum filter "${args[@]}"
    else
        gum filter "${args[@]}"
    fi
}
export -f gum::filter
