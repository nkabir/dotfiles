# starship
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::

# if starship is installed, use it
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi
