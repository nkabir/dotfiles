# Common Tasks

This guide covers frequently performed tasks when working with CWIQ Seed dotfiles.

## Daily Operations

### Update System

Update your entire environment:

```bash
# Update chezmoi and apply changes
chezmoi update

# Update system packages
sudo apt update && sudo apt upgrade  # Ubuntu
sudo yum update                       # AlmaLinux

# Update Homebrew packages
brew update && brew upgrade

# Update language packages
pip install --upgrade pip
npm update -g
```

### Check System Status

```bash
# Check git status across realms
~/.local/bin/realm-status.sh

# Check chezmoi status
chezmoi status
chezmoi diff

# Check system resources
htop
df -h
du -sh ~/realms/*
```

## File Management

### Add New Dotfiles

```bash
# Add a single file
chezmoi add ~/.config/newapp/config.toml

# Add a directory
chezmoi add ~/.config/newapp/

# Add with templates
chezmoi add --template ~/.gitconfig
```

### Edit Managed Files

```bash
# Edit via chezmoi (recommended)
chezmoi edit ~/.bashrc
chezmoi apply

# Edit directly and re-add
vim ~/.bashrc
chezmoi add ~/.bashrc
```

### Remove Managed Files

```bash
# Stop managing a file
chezmoi forget ~/.config/oldapp/config

# Remove from system and chezmoi
chezmoi remove ~/.config/oldapp/
```

## Bash Module Management

### List Available Modules

```bash
# Show all available modules
ls -la ~/.bashrc.avail/

# Show active modules
ls -la ~/.bashrc.d/

# Show inactive modules
comm -23 <(ls ~/.bashrc.avail/ | sort) <(ls ~/.bashrc.d/ | sort)
```

### Enable a Module

```bash
# Method 1: Symlink manually
ln -s ~/.bashrc.avail/300-docker.bash ~/.bashrc.d/

# Method 2: Use helper script
~/.scripts/after/run_after_900-link-bash.sh

# Reload shell
source ~/.bashrc
```

### Disable a Module

```bash
# Remove symlink
rm ~/.bashrc.d/300-docker.bash

# Reload shell
source ~/.bashrc
```

### Create Custom Module

```bash
# Create new module
cat > ~/.bashrc.avail/600-custom.bash << 'EOF'
# Custom bash configuration

# Add custom aliases
alias myproject='cd ~/realms/com/github/myproject'
alias serve='python -m http.server 8000'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Export custom variables
export CUSTOM_VAR="value"
EOF

# Enable it
ln -s ~/.bashrc.avail/600-custom.bash ~/.bashrc.d/
source ~/.bashrc
```

## Secret Management

### Using Bitwarden

```bash
# Login to Bitwarden
bw login

# Unlock vault
export BW_SESSION=$(bw unlock --raw)

# Get a secret
bw get item "GitHub Token" | jq -r '.login.password'

# Use in scripts
source ~/.local/lib/bitwarden/core.bash
bitwarden:init
TOKEN=$(bitwarden:get "GitHub" "token")
```

### Environment Variables

```bash
# Create local environment file
cat > ~/.env.local << 'EOF'
export SECRET_API_KEY="your-secret-key"
export DATABASE_PASSWORD="your-password"
EOF

# Source in .bashrc
echo "source ~/.env.local" >> ~/.bashrc.d/990-secrets.bash

# For specific projects
cd ~/realms/com/github/myproject
cat > .env.local << 'EOF'
API_KEY=project-specific-key
DB_PASS=project-specific-pass
EOF
```

## Development Workflows

### Start New Project

```bash
# Create realm
mkdir -p ~/realms/com/github/newproject
cd ~/realms/com/github/newproject

# Initialize git
git init
git remote add origin git@github.com:username/newproject.git

# Setup environment
cat > .envrc << 'EOF'
export PROJECT_NAME="newproject"
use asdf
layout node
PATH_add bin
EOF

# Allow direnv
direnv allow

# Initialize project
npm init -y
echo "node_modules/" >> .gitignore
```

### Clone Existing Project

```bash
# Clone to appropriate realm
git clone git@github.com:username/project.git \
    ~/realms/com/github/project

# Setup environment
cd ~/realms/com/github/project
direnv allow

# Install dependencies
[[ -f package.json ]] && npm install
[[ -f requirements.txt ]] && pip install -r requirements.txt
[[ -f Gemfile ]] && bundle install
```

### Switch Node/Python Versions

Using asdf:

```bash
# List available versions
asdf list all nodejs
asdf list all python

# Install specific version
asdf install nodejs 18.17.0
asdf install python 3.11.4

# Set for project
cd ~/realms/com/github/myproject
asdf local nodejs 18.17.0
asdf local python 3.11.4
```

## System Maintenance

### Clean Up Space

```bash
# Clean package caches
sudo apt clean              # Ubuntu
sudo yum clean all          # AlmaLinux
brew cleanup -s             # Homebrew

# Clean pip cache
pip cache purge

# Clean npm cache
npm cache clean --force

# Remove old kernels (Ubuntu)
sudo apt autoremove --purge

# Find large files
du -sh ~/.cache/* | sort -h
find ~ -type f -size +100M 2>/dev/null | head -20
```

### Backup Configurations

```bash
# Backup chezmoi config
tar -czf ~/backups/chezmoi-$(date +%Y%m%d).tar.gz \
    ~/.local/share/chezmoi \
    ~/.config/chezmoi

# Backup all dotfiles
tar -czf ~/backups/dotfiles-$(date +%Y%m%d).tar.gz \
    ~/.bashrc* \
    ~/.config \
    ~/.local/bin \
    ~/.local/lib

# Backup realms
~/.local/bin/realm-backup.sh com/github/important-project
```

### Fix Common Issues

```bash
# Fix chezmoi merge conflicts
chezmoi merge ~/.bashrc

# Regenerate chezmoi config
chezmoi init --apply

# Fix broken symlinks
find ~ -xtype l -delete

# Reset bash configuration
rm ~/.bashrc.d/*
~/.scripts/after/run_after_900-link-bash.sh
source ~/.bashrc

# Fix permission issues
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub
```

## Terminal Customization

### Change Shell Prompt

Edit `~/.bashrc.d/100-prompt.bash`:

```bash
# Simple prompt
PS1='\u@\h:\w\$ '

# Colorful prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Git-aware prompt
source /usr/share/git/git-prompt.sh
PS1='\u@\h:\w$(__git_ps1 " (%s)")\$ '
```

### Configure Terminal Colors

```bash
# Test colors
for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i
    if ! (( ($i + 1 ) % 8 )); then echo; fi
done

# Set LS_COLORS
eval $(dircolors ~/.dircolors)

# Configure less colors
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin standout
export LESS_TERMCAP_se=$'\E[0m'        # reset
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset
```

## Git Operations

### Configure Git Aliases

```bash
# Add to ~/.gitconfig via chezmoi
chezmoi edit ~/.gitconfig

[alias]
    st = status -sb
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
```

### Setup GPG Signing

```bash
# List GPG keys
gpg --list-secret-keys --keyid-format=long

# Configure git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# Export GPG key for GitHub
gpg --armor --export YOUR_KEY_ID | pbcopy
```

## Network Tools

### SSH Key Management

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github

# Configure SSH config
cat >> ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
EOF
```

### Port Forwarding

```bash
# Local port forward
ssh -L 8080:localhost:80 user@remote

# Remote port forward
ssh -R 9000:localhost:3000 user@remote

# SOCKS proxy
ssh -D 1080 user@remote
```

## Docker Management

### Clean Docker Resources

```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Remove everything unused
docker system prune -a -f --volumes

# Check space usage
docker system df
```

### Docker Shortcuts

Add to `~/.bashrc.d/300-docker.bash`:

```bash
# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'

# Docker compose aliases
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclog='docker-compose logs -f'
```

## Performance Optimization

### Speed Up Shell Startup

```bash
# Profile bash startup
time bash -i -c exit

# Debug slow startup
bash -x -i -c exit 2>&1 | ts '%.s' > bash-startup.log

# Disable slow modules
rm ~/.bashrc.d/slow-module.bash
```

### Optimize Git Performance

```bash
# Enable Git filesystem cache
git config core.fscache true

# Increase Git buffer size
git config http.postBuffer 524288000

# Enable parallel index
git config index.threads true
```