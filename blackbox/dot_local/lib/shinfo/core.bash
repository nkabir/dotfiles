# shinfo/core.bash
# shell script information
[ -n "$_SHINFO_CORE" ] && return 0
_SHINFO_CORE=1

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
shinfo::paths() {
  # Usage: shinfo::paths <script-path>
  # Uses realpath to determine various path components of the given script path.

  local script_path="$1"
  if [[ -z "$script_path" ]]; then
    logger::error "No script path provided to shinfo::paths"
    return 1
  fi

  # all lowercase variables are ephemeral and should be used as soon as possible
  declare -g paths__fa # full absolute path
  declare -g paths__da # directory absolute path
  declare -g paths__dr # directory relative (basename of directory)
  declare -g paths__fr # file relative (basename of file)
  declare -g paths__filename # filename without extension
  declare -g paths__extension # file extension

  paths__fa="$(realpath -m "$script_path")"
  paths__da="$(dirname "$paths__fa")"
  paths__dr="$(basename "$paths__da")"
  paths__fr="$(basename "$paths__fa")"
  paths__filename="${paths__fr%%.*}"
  paths__extension="${paths__fr##*.}"

  return 0

}
export -f shinfo::paths

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
shinfo::redo() {
  # Usage: shinfo::redo <redo-args>

  # ensure there are three arguments
  if [[ $# -lt 3 ]]; then
    logger::error "redo arguments were not provided to shinfo::redo"
    return 1
  fi

  declare -g redo__argv # all arguments as array
  declare -g redo__arg1
  declare -g redo__arg2
  declare -g redo__arg3
  declare -g redo__target_da

  redo__argv=($@) # all arguments as array
  redo__arg1="${redo__argv[0]}" # first argument
  redo__arg2="${redo__argv[1]}" # second argument
  redo__arg3="${redo__argv[2]}" # third argument
  redo__target_da="$(realpath -m $(dirname "${redo__arg2:?}"))"

}
export -f shinfo::redo
