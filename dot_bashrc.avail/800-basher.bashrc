export PATH="$HOME/.basher/bin:$PATH"
command -v "basher" >/dev/null 2>&1 && {
    eval "$(basher init - bash)"
}
