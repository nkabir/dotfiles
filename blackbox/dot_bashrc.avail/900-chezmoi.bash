# ChezMoi
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::

alias cz="chezmoi"

# check if __start_chezmoi is defined
# if not, source the completion script
if ! type -t __start_chezmoi &>/dev/null; then
    if [ -f "$HOME/.local/share/bash-completion/completions/chezmoi.bash" ]; then
	source "$HOME/.local/share/bash-completion/completions/chezmoi.bash"
	if [[ $(type -t compopt) = "builtin" ]]; then
	    complete -o default -F __start_chezmoi cz
	else
	    complete -o default -o nospace -F __start_chezmoi cz
	fi
    else
	echo "ChezMoi completion script not found."
    fi
fi
