# pyenv python version manager

[[ -z "${PYENV_INIT}" ]] && [[ -e "$HOME/.pyenv" ]] && {
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  export PYENV_INIT=true
} || true
