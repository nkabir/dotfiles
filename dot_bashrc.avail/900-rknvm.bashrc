# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bash user settings for rknvm
#
# regenerate with rkx::shell_add rknvm
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -e "${RKX_DA_MOUNT}/opt/rknvm" ]] && {
  use rknvm
  source nvm.sh
}


