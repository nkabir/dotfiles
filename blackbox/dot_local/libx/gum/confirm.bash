# gum/confirm.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::confirm [--affirmative <title>] [--negative <title>] [--default] [--timeout <duration>] [--prompt.<style>=<value> ...] [prompt]
# Arguments correspond to "gum confirm" CLI flags and prompt.
gum::confirm() {
    # shellcheck disable=SC2154
    local args=()
    local prompt=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --affirmative)
                args+=(--affirmative "$2")
                shift 2
                ;;
            --negative)
                args+=(--negative "$2")
                shift 2
                ;;
            --default)
                args+=(--default)
                shift
                ;;
            --timeout)
                args+=(--timeout "$2")
                shift 2
                ;;
            --prompt.*|--selected.*|--unselected.*)
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
                # First non-flag argument is the prompt
                if [[ -z "$prompt" ]]; then
                    prompt="$1"
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$prompt" ]]; then
        prompt="Are you sure?"
    fi

    # shellcheck disable=SC1091
    . "${GUM_HERE:?}/../logger/core.bash"

    if ! command -v gum >/dev/null 2>&1; then
        logger::error "gum CLI not found in PATH"
        return 2
    fi

    gum confirm "${args[@]}" "$prompt"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::info "User confirmed: $prompt"
    else
        logger::warn "User declined: $prompt"
    fi
    return $status
}
export -f gum::confirm
