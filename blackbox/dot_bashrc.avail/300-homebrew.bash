# homebrew

# if /home/linuxbrew exists, then run this command
if [ -d /home/linuxbrew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -f $HOME/.homebrew_profile ]; then
    . $HOME/.homebrew_profile
fi
