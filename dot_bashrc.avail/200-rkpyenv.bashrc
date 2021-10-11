# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bash user settings for rkpyenv
#
# regenerate with rkx::shell_add rkpyenv
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# pyenv python version manager


PYENV_ROOT="${RKX_DA_OPT:-${HOME}/.local/opt}/rkpyenv/pyenv"
PATH="${PYENV_ROOT}/bin:$PATH"
[[ -z "${PYENV_INIT}" ]] && [[ -e "${RKX_DA_OPT}/rkpyenv" ]] && {
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  export PYENV_INIT=true
} || true
