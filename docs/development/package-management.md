# Package Management

CWIQ Seed supports multiple package management strategies to handle software installation across different platforms and use cases.

## Overview

The system uses a layered approach:
1. **OS Package Managers** - System packages (apt, yum)
2. **Homebrew** - Cross-platform development tools
3. **Local Repositories** - Custom packages (.deb, pip)
4. **Language-Specific** - pip, npm, cargo, etc.

## OS Package Management

### Ubuntu (apt)

Packages are installed via `run_once_200-os-packages.sh.tmpl`:

```bash
{{- if .isUbuntu }}
# Update package list
sudo apt-get update

# Install packages
sudo apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    vim \
    htop
{{- end }}
```

**Adding packages:**
1. Edit `blackbox/dot_scripts/setup/run_once_200-os-packages.sh.tmpl`
2. Add to the appropriate OS section
3. Run `chezmoi apply`

### AlmaLinux (yum/dnf)

```bash
{{- if .isAlmaLinux }}
# Install EPEL repository
sudo yum install -y epel-release

# Install packages
sudo yum install -y \
    gcc \
    make \
    curl \
    git \
    wget \
    vim \
    htop
{{- end }}
```

## Homebrew

Homebrew provides consistent package management across platforms.

### Installation

Homebrew is installed automatically via setup scripts:

```bash
# Check if installed
command -v brew >/dev/null 2>&1 || {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
```

### Configuration

**Global Brewfile:** `~/.config/homebrew/Brewfile`

```ruby
# Taps
tap "homebrew/cask"
tap "homebrew/cask-fonts"

# Development tools
brew "git"
brew "gh"  # GitHub CLI
brew "node"
brew "python"
brew "go"
brew "rust"

# Utilities
brew "ripgrep"  # Fast grep
brew "fd"       # Fast find
brew "bat"      # Better cat
brew "exa"      # Better ls
brew "fzf"      # Fuzzy finder
brew "jq"       # JSON processor

# Casks (GUI applications)
cask "visual-studio-code"
cask "docker"
```

**Install packages:**
```bash
brew bundle --file=~/.config/homebrew/Brewfile
```

### Managing Packages

```bash
# Install a package
brew install package-name

# Update all packages
brew update && brew upgrade

# Search for packages
brew search keyword

# Get package info
brew info package-name

# List installed packages
brew list
```

## Local Debian Repository

For custom .deb packages not available in standard repositories.

### Setup

Initialize the repository:
```bash
~/.local/bin/deb-repo-init.sh
```

This creates:
- Repository at `~/.local/share/deb-repo/`
- APT source at `/etc/apt/sources.list.d/local.list`
- GPG key for package signing

### Adding Packages

**From local file:**
```bash
~/.local/bin/deb-repo-add.sh /path/to/package.deb
```

**From URL:**
```bash
~/.local/bin/deb-repo-add.sh https://example.com/package.deb
```

**Batch addition:**
```bash
# Add all .deb files in directory
for deb in *.deb; do
    ~/.local/bin/deb-repo-add.sh "$deb"
done
```

### Using the Repository

```bash
# Update package list
sudo apt update

# Install from local repo
sudo apt install package-name
```

## Python Package Management

### System Python

Use pip with user flag to avoid system conflicts:

```bash
# Install for user
pip install --user package-name

# Upgrade pip itself
python -m pip install --upgrade pip
```

### Virtual Environments

**Using venv:**
```bash
# Create environment
python -m venv ~/envs/myproject

# Activate
source ~/envs/myproject/bin/activate

# Install packages
pip install package-name
```

**Using uv (fast Python package manager):**
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create project
uv init myproject
cd myproject

# Add dependencies
uv add requests pandas

# Run with dependencies
uv run python script.py
```

### Local PyPI Repository

For private Python packages:

```bash
# Setup local index
mkdir -p ~/.local/share/pypi-repo

# Configure pip
echo "[global]
extra-index-url = file://$HOME/.local/share/pypi-repo/simple
trusted-host = localhost" >> ~/.config/pip/pip.conf
```

## Node.js Package Management

### Global Packages

Install development tools globally:

```bash
# Set npm prefix
npm config set prefix ~/.local

# Install global packages
npm install -g \
    typescript \
    eslint \
    prettier \
    nodemon
```

### Project Dependencies

```bash
# Initialize project
npm init -y

# Add dependencies
npm install express

# Add dev dependencies
npm install --save-dev jest

# Install from package.json
npm install
```

### Using pnpm

Faster, more efficient npm alternative:

```bash
# Install pnpm
npm install -g pnpm

# Use like npm
pnpm install
pnpm add package-name
```

## Container Management

### Docker Images

```bash
# Pull images
docker pull ubuntu:latest
docker pull node:18-alpine

# Build custom images
docker build -t myapp:latest .

# Save for offline use
docker save myapp:latest | gzip > myapp.tar.gz
```

### Podman (Rootless Alternative)

```bash
# Install podman
sudo apt install podman  # Ubuntu
sudo yum install podman  # AlmaLinux

# Use like Docker
podman pull alpine
podman run -it alpine sh
```

## Package Caching

### APT Cache

```bash
# Cache packages locally
sudo apt-get install apt-cacher-ng

# Configure in ~/.bashrc
export APT_CACHE="http://localhost:3142"
```

### Homebrew Cache

```bash
# Set cache directory
export HOMEBREW_CACHE="$HOME/.cache/homebrew"

# Download without installing
brew fetch package-name
```

### pip Cache

```bash
# Configure cache location
export PIP_CACHE_DIR="$HOME/.cache/pip"

# Download packages
pip download package-name -d ~/.cache/pip-offline/

# Install from cache
pip install --no-index --find-links ~/.cache/pip-offline/ package-name
```

## Version Management

### asdf-vm

Universal version manager for multiple languages:

```bash
# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# Add to shell
. "$HOME/.asdf/asdf.sh"

# Install plugins
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby

# Install versions
asdf install nodejs 18.17.0
asdf install python 3.11.4

# Set defaults
asdf global nodejs 18.17.0
asdf global python 3.11.4
```

### Project-Specific Versions

Create `.tool-versions`:
```
nodejs 18.17.0
python 3.11.4
ruby 3.2.2
```

## Best Practices

### 1. Prefer User Installations

```bash
# Good: User installation
pip install --user package
npm install -g package  # with prefix=~/.local

# Avoid: System-wide
sudo pip install package
sudo npm install -g package
```

### 2. Document Dependencies

Create `requirements.txt` for Python:
```bash
pip freeze > requirements.txt
```

Create `Brewfile` for Homebrew:
```bash
brew bundle dump --file=~/.config/homebrew/Brewfile
```

### 3. Use Version Constraints

**Python:**
```
requests>=2.28.0,<3.0.0
pandas~=1.5.0
```

**Node.js:**
```json
{
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "~4.17.21"
  }
}
```

### 4. Regular Updates

```bash
# Update script
#!/bin/bash
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Updating Homebrew..."
brew update && brew upgrade

echo "Updating pip packages..."
pip list --outdated --user | cut -d' ' -f1 | xargs -n1 pip install -U --user

echo "Updating npm packages..."
npm update -g
```

## Troubleshooting

### Broken Dependencies

```bash
# Ubuntu/Debian
sudo apt-get install -f
sudo dpkg --configure -a

# AlmaLinux
sudo yum check
sudo yum reinstall package-name
```

### Permission Issues

```bash
# Fix npm permissions
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
```

### Cache Corruption

```bash
# Clear caches
rm -rf ~/.cache/pip
brew cleanup -s
npm cache clean --force
```