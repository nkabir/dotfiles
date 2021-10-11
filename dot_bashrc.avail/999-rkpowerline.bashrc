# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# bash user settings for rkpowerline
#
# regenerate with rkx::shell_add rkpowerline
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Python version was too slow
# https://github.com/justjanne/powerline-go#installation
POWER="${RKX_DA_MOUNT:-}/opt/rkpowerline/bin/powerline-go"

function _update_ps1() {
    PS1="$(${POWER} -mode patched -shell bash -colorize-hostname -condensed -error $?)"
}

if [[ "$TERM" != "dumb"  ]] && \
       [[ "$TERM" != "linux" ]] && \
       [[ -f "${POWER}" ]]; then
    export PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

