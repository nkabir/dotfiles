# gum/table.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::table - Render a table of data (wrapper for gum table)
# Usage:
# gum::table [--columns ...] [--widths ...] [--height ...] [--file ...] [--separator ...] [--cell.* ...] [--header.* ...] [--selected.* ...] [input]
gum::table() {
    local args=()
    local input=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --columns|-c)
                args+=(--columns "$2")
                shift 2
                ;;
            --widths|-w)
                args+=(--widths "$2")
                shift 2
                ;;
            --height)
                args+=(--height "$2")
                shift 2
                ;;
            --file|-f)
                args+=(--file "$2")
                shift 2
                ;;
            --separator|-s)
                args+=(--separator "$2")
                shift 2
                ;;
            --cell.*|--header.*|--selected.*)
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                args+=("$1")
                shift
                ;;
            *)
                # First non-flag argument is input (for piped/cat data)
                if [[ -z "$input" ]]; then
                    input="$1"
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

    if [[ -n "$input" ]]; then
        echo "$input" | gum table "${args[@]}"
    else
        gum table "${args[@]}"
    fi
}
export -f gum::table
