#!/usr/bin/env bash

# logger::config
# Set these variables to control output
LOGGER_OUTPUT="both"      # Options: "terminal", "syslog", "both"
LOGGER_SYSLOG_TAG="logger" # Syslog tag

# ANSI color codes
LOGGER_COLOR_RESET="\e[0m"
LOGGER_COLOR_DEBUG="\e[36m"    # Cyan
LOGGER_COLOR_INFO="\e[32m"     # Green
LOGGER_COLOR_WARN="\e[33m"     # Yellow
LOGGER_COLOR_ERROR="\e[31m"    # Red
LOGGER_COLOR_CRITICAL="\e[1;31m" # Bold Red

# logger::log <level> <message>
logger::log() {
    local level="$1"
    shift
    local message="$*"
    local color
    local syslog_level

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
            ;;
    esac

    # Format message with timestamp and level
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local formatted="[$timestamp] [$level] $message"

    # Output to terminal
    if [[ "$LOGGER_OUTPUT" == "terminal" || "$LOGGER_OUTPUT" == "both" ]]; then
        echo -e "${color}${formatted}${LOGGER_COLOR_RESET}" | ccze -A
    fi

    # Output to syslog (no color)
    if [[ "$LOGGER_OUTPUT" == "syslog" || "$LOGGER_OUTPUT" == "both" ]]; then
        logger -t "$LOGGER_SYSLOG_TAG" -p "user.${syslog_level}" "$formatted"
    fi
}

# Convenience wrappers
logger::debug()    { logger::log DEBUG "$@"; }
logger::info()     { logger::log INFO "$@"; }
logger::warn()     { logger::log WARN "$@"; }
logger::error()    { logger::log ERROR "$@"; }
logger::critical() { logger::log CRITICAL "$@"; }

# Example usage:
# logger::info "This is an info message"
# logger::error "This is an error message"
# LOGGER_OUTPUT="syslog" logger::warn "This goes only to syslog"
