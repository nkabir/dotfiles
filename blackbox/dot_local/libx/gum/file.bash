# gum/file.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


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
