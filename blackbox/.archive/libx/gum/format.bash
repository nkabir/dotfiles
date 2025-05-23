# gum/format.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::format [--type <type>] [TEMPLATE...]
# Arguments correspond to "gum format" CLI flags and templates.
gum::format() {
    # shellcheck disable=SC2154
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type|-t)
                args+=(--type "$2")
                shift 2
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Positional arguments (template strings)
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

    gum format "${args[@]}"
}
export -f gum::format
