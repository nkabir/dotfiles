# gum/choose.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


gum::choose() {
  # Log the invocation
  logger::debug "Invoking gum choose with args: $*"

  # Call gum choose with all passed arguments
  gum choose "$@"
}
export -f gum::choose
