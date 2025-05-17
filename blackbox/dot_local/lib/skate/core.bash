# skate/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_SKATE_CORE" ] && return 0
_SKATE_CORE=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
skate::delete() {
    # Usage: skate::delete [--force] <key>
    local force=""
    local key=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force="--force"
                shift
                ;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                key="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$key" ]]; then
        logger::error "No key specified for skate::delete"
        return 2
    fi

    if skate delete $force "$key"; then
        logger::info "Deleted key: $key"
    else
        logger::error "Failed to delete key: $key"
        return 3
    fi
}
export -f skate::delete


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
skate::delete-db() {
    # Usage: skate::delete-db [--force] <database-name>
    local force=""
    local db_name=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force="--force"
                shift
                ;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                db_name="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$db_name" ]]; then
        logger::error "No database specified for skate::delete-db"
        return 2
    fi

    if skate delete-db $force "$db_name"; then
        logger::info "Deleted database: $db_name"
    else
        logger::error "Failed to delete database: $db_name"
        return 3
    fi
}
export -f skate::delete-db


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
skate::get() {
    # Usage: skate::get [--default <value>] <key>
    local default=""
    local key=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --default)
                default="$2"
                shift 2
                ;;
            -*)
                logger::error "Unknown option: $1"
                return 1
                ;;
            *)
                key="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$key" ]]; then
        logger::error "No key specified for skate::get"
        return 2
    fi

    local value
    if ! value="$(skate get "$key" 2>/dev/null)"; then
        if [[ -n "$default" ]]; then
            logger::info "Key not found: $key, returning default: $default"
            echo "$default"
            return 0
        else
            logger::error "Failed to get key: $key"
            return 3
        fi
    fi

    echo "$value"
}
export -f skate::get
