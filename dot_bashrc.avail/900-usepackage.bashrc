# need a bash-specific script because direnv does not support exporting functions from witin bash scripts

[[ -f "/usr/share/usepackage/use.bsh" ]] && {
  source /usr/share/usepackage/use.bsh
  BENCH_PACKAGES_PATH="${LABKEY_DA:?}/bench"
}

[[ -e "${BENCH_PACKAGES_PATH}" ]] && {
  export PACKAGES_PATH="${BENCH_PACKAGES_PATH:?}"
} || {
  export PACKAGES_PATH=/etc
}

