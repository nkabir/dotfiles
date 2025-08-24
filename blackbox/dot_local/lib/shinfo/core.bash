# shinfo/core.bash
# shell script information
[ -n "$_SHINFO_CORE" ] && return 0
_SHINFO_CORE=1

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
shinfo::paths() {
  # Usage: shinfo::paths <script-path>
  # Uses declare to set absolute_path, directory, base name, file name, and extension of the script

  local script_path="$1"
  if [[ -z "$script_path" ]]; then
    logger::error "No script path provided to shinfo::paths"
    return 1
  fi

  # all lowercase variables are ephemeral and should be used as soon as possible
  declare -g absolute_path
  declare -g directory
  declare -g base_name
  declare -g file_name
  declare -g extension

  absolute_path="$(realpath -m "$script_path")"
  directory="$(dirname "$absolute_path")"
  base_name="$(basename "$absolute_path")"
  file_name="${base_name%%.*}"
  extension="${base_name##*.}"

  return 0

}
