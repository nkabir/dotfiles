# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bash user settings for rkdirenv
#
# regenerate with rkx::shell_add rkdirenv
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# if direnv exists, enable it in shell
command -v direnv > /dev/null && {
    direnv allow . 
    eval "$(direnv hook bash)" 
    eval "$(direnv export bash)"
}

