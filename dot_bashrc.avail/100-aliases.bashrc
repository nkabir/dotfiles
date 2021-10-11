# Aliases
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
alias l="ls -lhSt --color"
alias ll="ls -F --color"
alias mroe=more
alias la="ls -lat --color"

alias y="yadm"
alias rp="use rkpy3 && redo clean.pages && redo all.pages"

# alias venv="source virtualenvwrapper.sh"
alias hysh="hy --repl-output-fn=hy.contrib.hy-repr.hy-repr"
alias weather="curl wttr.in && ansiweather -l chicago -f 10 -u imperial"

# move to docker config
# alias dc="docker container"
# alias di="docker image"


# alias wm="watchman"
# TODO move to dedicated PATH file
# export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
