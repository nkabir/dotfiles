# gum/write.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::write [--width N] [--height N] [--placeholder TEXT] [--value TEXT] [--char-limit N] [--header TEXT] [--show-line-numbers] [--prompt.<style>=<value> ...]
# Arguments correspond to "gum write" CLI flags and prompt.
gum::write() {
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --width|--height|--placeholder|--value|--char-limit|--header)
                args+=("$1" "$2")
                shift 2
                ;;
            --show-line-numbers)
                args+=("$1")
                shift
                ;;
            --prompt.*|--header.*|--cursor-line-number.*)
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                args+=("$1")
                shift
                ;;
            *)
                # Unexpected positional arguments are ignored for gum write
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

    gum write "${args[@]}"
}
export -f gum::write
