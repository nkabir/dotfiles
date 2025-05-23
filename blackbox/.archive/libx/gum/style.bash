# gum/style.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::style [--foreground <color>] [--background <color>] [--bold] [--faint] [--italic] [--underline] [--strikethrough] [--border <style>] [--border-foreground <color>] [--border-background <color>] [--width <n>] [--height <n>] [--padding <n>] [--margin <n>] [--align <alignment>] [text ...]
# Arguments correspond to "gum style" CLI flags and text.
gum::style() {
    local args=()
    local text=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --foreground|--background|--border|--border-foreground|--border-background|--width|--height|--padding|--margin|--align)
                args+=("$1" "$2")
                shift 2
                ;;
            --bold|--faint|--italic|--underline|--strikethrough)
                args+=("$1")
                shift
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Collect positional arguments as text
                text+=("$1")
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

    gum style "${args[@]}" "${text[@]}"
}
export -f gum::style
