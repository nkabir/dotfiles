# starship
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::

# TODO add support to display git status
# TODO add support to display current shell level

# if starship is installed, use it
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi
