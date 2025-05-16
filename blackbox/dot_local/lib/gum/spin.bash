# gum/spin.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::spin [--show-output] [--spinner <type>] [--title <text>] [--align <arg>] [--spinner.<style>=<value>] [--title.<style>=<value>] -- <command> [args...]
# Arguments correspond to "gum spin" CLI flags and command.
gum::spin() {
    local args=()
    local cmd=()
    local found_double_dash=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --show-output)
                args+=(--show-output)
                shift
                ;;
            --spinner|-s)
                args+=(--spinner "$2")
                shift 2
                ;;
            --title)
                args+=(--title "$2")
                shift 2
                ;;
            --align|-a)
                args+=(--align "$2")
                shift 2
                ;;
            --spinner.*|--title.*)
                args+=("$1" "$2")
                shift 2
                ;;
            --)
                found_double_dash=1
                shift
                ;;
            *)
                if [[ $found_double_dash -eq 1 ]]; then
                    cmd+=("$1")
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    # Load logger
    . "${GUM_HERE:?}/../logger/core.bash"

    if ! command -v gum >/dev/null 2>&1; then
        logger::error "gum CLI not found in PATH"
        return 2
    fi

    if [[ ${#cmd[@]} -eq 0 ]]; then
        logger::error "No command specified for spinner"
        return 3
    fi

    gum spin "${args[@]}" -- "${cmd[@]}"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::info "gum spin completed successfully"
    else
        logger::warn "gum spin failed with status $status"
    fi
    return $status
}
export -f gum::spin
