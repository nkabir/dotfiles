# logger/core.bash - Improved Logging Library
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::

[ -n "$_LOGGER_CORE" ] && return 0
_LOGGER_CORE=1

# logger::configure - Configuration function
# Set these variables to control output behavior
LOGGER_OUTPUT="${LOGGER_OUTPUT:-both}"      # Options: "terminal", "syslog", "both"
LOGGER_SYSLOG_TAG="${LOGGER_SYSLOG_TAG:-$(basename "${0:-logger}")}" # Syslog tag
LOGGER_MIN_LEVEL="${LOGGER_MIN_LEVEL:-DEBUG}" # Minimum log level to output
LOGGER_TIMESTAMP_FORMAT="${LOGGER_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S %Z}" # Timestamp format
LOGGER_ENABLE_COLORS="${LOGGER_ENABLE_COLORS:-auto}" # Options: "auto", "always", "never"

# Validate configuration
logger::validate_config() {
    case "$LOGGER_OUTPUT" in
        terminal|syslog|both) ;;
        *)
            echo "Warning: Invalid LOGGER_OUTPUT '$LOGGER_OUTPUT', using 'both'" >&2
            LOGGER_OUTPUT="both"
            ;;
    esac

    case "$LOGGER_ENABLE_COLORS" in
        auto|always|never) ;;
        *)
            echo "Warning: Invalid LOGGER_ENABLE_COLORS '$LOGGER_ENABLE_COLORS', using 'auto'" >&2
            LOGGER_ENABLE_COLORS="auto"
            ;;
    esac
}

# Initialize color codes based on terminal capability and configuration
logger::init_colors() {
    local use_colors=false

    case "$LOGGER_ENABLE_COLORS" in
        always)
            use_colors=true
            ;;
        never)
            use_colors=false
            ;;
        auto)
            # Check if output is a terminal and supports colors
            if [[ -t 2 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
                use_colors=true
            fi
            ;;
    esac

    if [[ "$use_colors" == "true" ]]; then
        LOGGER_COLOR_RESET="\e[0m"
        LOGGER_COLOR_DEBUG="\e[36m"    # Cyan
        LOGGER_COLOR_INFO="\e[32m"     # Green
        LOGGER_COLOR_WARN="\e[33m"     # Yellow
        LOGGER_COLOR_ERROR="\e[31m"    # Red
        LOGGER_COLOR_CRITICAL="\e[1;31m" # Bold Red
    else
        LOGGER_COLOR_RESET=""
        LOGGER_COLOR_DEBUG=""
        LOGGER_COLOR_INFO=""
        LOGGER_COLOR_WARN=""
        LOGGER_COLOR_ERROR=""
        LOGGER_COLOR_CRITICAL=""
    fi
}

# Check if a log level should be output based on minimum level
logger::should_log() {
    local level="$1"
    local levels=("DEBUG" "INFO" "WARN" "ERROR" "CRITICAL")
    local level_num=-1
    local min_num=-1

    # Find numeric values for levels
    for i in "${!levels[@]}"; do
        [[ "${levels[$i]}" == "$level" ]] && level_num=$i
        [[ "${levels[$i]}" == "$LOGGER_MIN_LEVEL" ]] && min_num=$i
    done

    # If either level is unknown, allow logging (fail safe)
    [[ $level_num -eq -1 || $min_num -eq -1 ]] && return 0

    # Check if current level meets minimum threshold
    [[ $level_num -ge $min_num ]]
}

# Sanitize log message to prevent log injection
logger::sanitize_message() {
    local message="$*"
    # Remove control characters except newlines and tabs
    printf '%s' "$message" | tr -d '\000-\010\013\014\016-\037\177-\377'
}

# logger::log - Core logging function
# Usage: logger::log <level> <message...>
# Arguments:
#   level   - Log level (DEBUG, INFO, WARN, WARNING, ERROR, CRITICAL)
#   message - Log message (remaining arguments)
# Globals:
#   LOGGER_OUTPUT - Output destination
#   LOGGER_SYSLOG_TAG - Syslog tag
#   LOGGER_MIN_LEVEL - Minimum level to log
logger::log() {
    local level="$1"
    shift
    local message
    message="$(logger::sanitize_message "$*")"
    local color
    local syslog_level

    # Check if we should log this level
    if ! logger::should_log "$level"; then
        return 0
    fi

    # Map log levels to colors and syslog priorities
    case "$level" in
        DEBUG)
            color="$LOGGER_COLOR_DEBUG"
            syslog_level="debug"
            ;;
        INFO)
            color="$LOGGER_COLOR_INFO"
            syslog_level="info"
            ;;
        WARN|WARNING)
            color="$LOGGER_COLOR_WARN"
            syslog_level="warning"
            level="WARN"  # Normalize to WARN
            ;;
        ERROR)
            color="$LOGGER_COLOR_ERROR"
            syslog_level="err"
            ;;
        CRITICAL)
            color="$LOGGER_COLOR_CRITICAL"
            syslog_level="crit"
            ;;
        *)
            color="$LOGGER_COLOR_RESET"
            syslog_level="notice"
            level="UNKNOWN"
            ;;
    esac

    # Format message with timestamp and level
    local timestamp
    if ! timestamp="$(date "+$LOGGER_TIMESTAMP_FORMAT" 2>/dev/null)"; then
        # Fallback if custom format fails
        timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    fi
    local formatted="[$timestamp] [$level] $message"

    # Output to terminal if configured
    if [[ "$LOGGER_OUTPUT" == "terminal" || "$LOGGER_OUTPUT" == "both" ]]; then
        local terminal_output="${color}${formatted}${LOGGER_COLOR_RESET}"

        # Debug: Force output to see what's happening
        # echo "DEBUG: Outputting to terminal: $terminal_output" >&2

        # Use ccze for colorization if available, otherwise plain output
        if command -v ccze >/dev/null 2>&1; then
            if ! echo -e "$terminal_output" | ccze -A >&2 2>/dev/null; then
                # Fallback if ccze fails
                echo -e "$terminal_output" >&2
            fi
        else
            echo -e "$terminal_output" >&2
        fi
    fi

    # Output to syslog if configured
    if [[ "$LOGGER_OUTPUT" == "syslog" || "$LOGGER_OUTPUT" == "both" ]]; then
        if command -v logger >/dev/null 2>&1; then
            if ! logger -t "$LOGGER_SYSLOG_TAG" -p "user.${syslog_level}" "$formatted" 2>/dev/null; then
                # Fallback: write to stderr if syslog fails
                echo "SYSLOG_ERROR: Failed to write to syslog: $formatted" >&2
            fi
        else
            echo "SYSLOG_ERROR: logger command not available: $formatted" >&2
        fi
    fi
}
export -f logger::log

# logger::configure - Runtime configuration function
# Usage: logger::configure [--output terminal|syslog|both] [--tag TAG] [--min-level LEVEL] [--colors auto|always|never]
logger::configure() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output)
                case "$2" in
                    terminal|syslog|both)
                        LOGGER_OUTPUT="$2"
                        ;;
                    *)
                        echo "Error: Invalid output option '$2'. Use: terminal, syslog, or both" >&2
                        return 1
                        ;;
                esac
                shift 2
                ;;
            --tag)
                LOGGER_SYSLOG_TAG="$2"
                shift 2
                ;;
            --min-level)
                case "$2" in
                    DEBUG|INFO|WARN|ERROR|CRITICAL)
                        LOGGER_MIN_LEVEL="$2"
                        ;;
                    *)
                        echo "Error: Invalid log level '$2'. Use: DEBUG, INFO, WARN, ERROR, or CRITICAL" >&2
                        return 1
                        ;;
                esac
                shift 2
                ;;
            --colors)
                case "$2" in
                    auto|always|never)
                        LOGGER_ENABLE_COLORS="$2"
                        logger::init_colors  # Reinitialize colors
                        ;;
                    *)
                        echo "Error: Invalid color option '$2'. Use: auto, always, or never" >&2
                        return 1
                        ;;
                esac
                shift 2
                ;;
            --timestamp-format)
                LOGGER_TIMESTAMP_FORMAT="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Usage: logger::configure [--output terminal|syslog|both] [--tag TAG] [--min-level LEVEL] [--colors auto|always|never] [--timestamp-format FORMAT]" >&2
                return 1
                ;;
        esac
    done
}
export -f logger::configure

# logger::log_structured - Structured logging with key-value pairs
# Usage: logger::log_structured <level> <message> [key value ...]
logger::log_structured() {
    local level="$1"
    local message="$2"
    shift 2

    local structured=""
    while [[ $# -gt 1 ]]; do
        structured+=" $1=$2"
        shift 2
    done

    logger::log "$level" "$message$structured"
}
export -f logger::log_structured

# Convenience wrapper functions
logger::debug()    { logger::log DEBUG "$@"; }
export -f logger::debug

logger::info()     { logger::log INFO "$@"; }
export -f logger::info

logger::warn()     { logger::log WARN "$@"; }
export -f logger::warn

logger::warning()  { logger::log WARN "$@"; }  # Alias for warn
export -f logger::warning

logger::error()    { logger::log ERROR "$@"; }
export -f logger::error

logger::critical() { logger::log CRITICAL "$@"; }
export -f logger::critical

# logger::debug_state - Debug function to show current logger state
logger::debug_state() {
    echo "=== Logger Debug State ===" >&2
    echo "LOGGER_OUTPUT: '$LOGGER_OUTPUT'" >&2
    echo "LOGGER_MIN_LEVEL: '$LOGGER_MIN_LEVEL'" >&2
    echo "LOGGER_ENABLE_COLORS: '$LOGGER_ENABLE_COLORS'" >&2
    echo "LOGGER_SYSLOG_TAG: '$LOGGER_SYSLOG_TAG'" >&2
    echo "Colors initialized: $([ -n "$LOGGER_COLOR_INFO" ] && echo "yes" || echo "no")" >&2
    echo "Terminal check: $([ -t 2 ] && echo "is tty" || echo "not tty")" >&2
    echo "TERM: '${TERM:-unset}'" >&2
    echo "NO_COLOR: '${NO_COLOR:-unset}'" >&2
    echo "ccze available: $(command -v ccze >/dev/null 2>&1 && echo "yes" || echo "no")" >&2
    echo "logger available: $(command -v logger >/dev/null 2>&1 && echo "yes" || echo "no")" >&2
    echo "==========================" >&2
}
export -f logger::debug_state

# Initialize the logger
logger::validate_config
logger::init_colors

# Example usage:
# logger::info "This is an info message"
# logger::error "This is an error message"
# logger::configure --output terminal --min-level WARN
# logger::log_structured INFO "User login" user "alice" ip "192.168.1.1"
# LOGGER_OUTPUT="syslog" logger::warn "This goes only to syslog"
