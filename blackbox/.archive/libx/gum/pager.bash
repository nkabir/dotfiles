# gum/pager.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::pager [--show-line-numbers] [--height <lines>] [--width <cols>] [--background <color>] [--foreground <color>] [--border <style>] [--border-foreground <color>] [--border-background <color>] [--margin <n>] [--padding <n>] [--help] [file...]
# Arguments correspond to "gum pager" CLI flags and file input.
gum::pager() {
    local args=()
    local files=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --show-line-numbers|--help)
                args+=("$1")
                shift
                ;;
            --height|--width|--background|--foreground|--border|--border-foreground|--border-background|--margin|--padding)
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Non-flag argument: treat as file
                files+=("$1")
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

    if [[ ${#files[@]} -gt 0 ]]; then
        gum pager "${args[@]}" "${files[@]}"
    else
        gum pager "${args[@]}"
    fi
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::info "gum pager exited successfully"
    else
        logger::warn "gum pager exited with status $status"
    fi
    return $status
}
export -f gum::pager
