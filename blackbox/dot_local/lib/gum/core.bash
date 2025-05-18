# gum/core.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_GUM_CORE" ] && return 0
_GUM_CORE=1

GUM_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


# write    : Prompt for long-form text
. "${GUM_HERE:?}/write.bash"

# log      : Log messages to output
. "${GUM_HERE:?}/log.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gum::choose() {
  # Log the invocation
  logger::debug "Invoking gum choose with args: $*"

  # Call gum choose with all passed arguments
  gum choose "$@"
}
export -f gum::choose


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


# gum::file - Wrapper for 'gum file' with structured logging and path support
# Usage: gum::file [--width <int>] [--height <int>] [--value <string>] [--placeholder <string>] [--header <string>] [--show-line-numbers] [--cursor-line <int>] [PATH]
gum::file() {
  local args=()
  local path=""

  logger::debug "gum::file called with arguments: $*"

  # Parse flags and collect the path if present
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --width|--height|--value|--placeholder|--header|--cursor-line)
        logger::debug "Parsing option $1 with value $2"
        args+=("$1" "$2")
        shift 2
        ;;
      --show-line-numbers)
        logger::debug "Parsing flag $1"
        args+=("$1")
        shift
        ;;
      --) # Explicit end of options
        shift
        if [[ $# -gt 0 ]]; then
          path="$1"
          logger::debug "Explicit path argument: $path"
          shift
        fi
        ;;
      -*)
        logger::error "Unknown flag: $1"
        return 1
        ;;
      *)
        # First positional argument after options is treated as PATH
        path="$1"
        logger::debug "Detected positional path argument: $path"
        shift
        ;;
    esac
  done

  logger::info "Running: gum file ${args[*]}${path:+ -- $path}"
  gum file "${args[@]}" ${path:+-- "$path"}
}
export -f gum::file

# Example usage:
# gum::file --width 60 --height 10 --value "Hello, world!" --placeholder "Type here..." --header "Edit the file" --show-line-numbers --cursor-line 2 ./myfile.txt


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::filter [--placeholder <text>] [--limit <n>|--no-limit] [--height <n>] [--width <n>] [--header <text>] [--indicator <text>] [--selected.<style>=<val> ...] [--unselected.<style>=<val> ...] [--prompt.<style>=<val> ...] [input ...]
# Arguments correspond to "gum filter" CLI flags and input.

gum::filter() {
    local args=()
    local input_from_stdin=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --placeholder)
                args+=(--placeholder "$2")
                shift 2
                ;;
            --limit)
                args+=(--limit "$2")
                shift 2
                ;;
            --no-limit)
                args+=(--no-limit)
                shift
                ;;
            --height)
                args+=(--height "$2")
                shift 2
                ;;
            --width)
                args+=(--width "$2")
                shift
                ;;
            --header)
                args+=(--header "$2")
                shift 2
                ;;
            --indicator)
                args+=(--indicator "$2")
                shift 2
                ;;
            --selected.*|--unselected.*|--prompt.*)
                args+=("$1" "$2")
                shift 2
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            -)
                # Explicit stdin indicator
                input_from_stdin=1
                shift
                ;;
            *)
                # Treat as input value (if not reading from stdin)
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

    if [[ $input_from_stdin -eq 1 || ! -t 0 ]]; then
        gum filter "${args[@]}"
    else
        gum filter "${args[@]}"
    fi
}
export -f gum::filter


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


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gum::input [--placeholder <text>] [--password] [--value <default>] [--width <cols>] [--prompt.<style>=<value> ...]
# Arguments correspond to "gum input" CLI flags.
gum::input() {
    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --placeholder)
                args+=(--placeholder "$2")
                shift 2
                ;;
            --password)
                args+=(--password)
                shift
                ;;
            --value)
                args+=(--value "$2")
                shift 2
                ;;
            --width)
                args+=(--width "$2")
                shift 2
                ;;
            --prompt.*|--cursor.*|--header.*|--width.*)
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
                # Any non-flag argument is ignored (gum input does not take positional args)
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

    gum input "${args[@]}"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::info "gum input completed"
    else
        logger::warn "gum input failed or was cancelled"
    fi
    return $status
}
export -f gum::input


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::join [--align <left|center|right|top|middle|bottom>] [--horizontal|--vertical] <text...>
# Arguments correspond to "gum join" CLI flags and text arguments.
gum::join() {
    local args=()
    local align=""
    local direction=""
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --align)
                align="$2"
                args+=(--align "$2")
                shift 2
                ;;
            --horizontal|--vertical)
                direction="$1"
                args+=("$1")
                shift
                ;;
            --*)
                # Unknown flag, pass through
                args+=("$1")
                shift
                ;;
            *)
                # Text arguments
                break
                ;;
        esac
    done

    # Remaining arguments are text to join
    local text_args=()
    while [[ $# -gt 0 ]]; do
        text_args+=("$1")
        shift
    done

    # Logging
    . "${GUM_HERE:?}/../logger/core.bash"
    if ! command -v gum >/dev/null 2>&1; then
        logger::error "gum CLI not found in PATH"
        return 2
    fi

    # Run gum join with all arguments
    gum join "${args[@]}" "${text_args[@]}"
    local status=$?
    if [[ $status -eq 0 ]]; then
        logger::debug "gum join succeeded"
    else
        logger::error "gum join failed"
    fi
    return $status
}
export -f gum::join


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


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# gum::log [--level <level>] [--structured] [--time <layout>] [--format <format>] [message] [key value ...]
# Arguments correspond to "gum log" CLI flags and message.
gum::log() {
    local args=()
    local message=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --level)
                args+=(--level "$2")
                shift 2
                ;;
            --structured|-s)
                args+=(--structured)
                shift
                ;;
            --time)
                args+=(--time "$2")
                shift 2
                ;;
            --format|-t)
                args+=(--format "$2")
                shift 2
                ;;
            --*)
                args+=("$1")
                shift
                ;;
            *)
                # First non-flag argument is the message
                if [[ -z "$message" ]]; then
                    message="$1"
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

    gum log "${args[@]}" "$message"

}
export -f gum::log
