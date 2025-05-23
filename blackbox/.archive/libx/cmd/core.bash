# lib/command/core.bash
# shellcheck shell=bash
#
# utilities for command line
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# check if command exists
cmd::check() {

  # shellcheck disable=SC2154
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    return 1
  fi
  return 0
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# return path to command
# don't return alias
cmd::path() {

  # shellcheck disable=SC2154
  local cmd="$1"
  if ! cmd::check "$cmd"; then
    return 1
  fi

  # shellcheck disable=SC2154
  local path
  path="$(command -v "$cmd")"
  echo "$path"
}
