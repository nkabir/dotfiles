# homebrew

# if /home/linuxbrew exists, then run this command
if [ -d /home/linuxbrew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
