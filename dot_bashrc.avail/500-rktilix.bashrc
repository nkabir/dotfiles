# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bash user settings for rktilix
#
# regenerate with rkx::shell_add rktilix
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# https://gnunn1.github.io/tilix-web/manual/vteconfig/

# required for opening new tabs in same folder

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  . /etc/profile.d/vte.sh
fi
