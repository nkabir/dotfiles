# Scripts Reference

Comprehensive reference for all scripts in the CWIQ Seed dotfiles system.

## Script Types

### Chezmoi Scripts

Located in `blackbox/dot_scripts/`:

| Type | Prefix | When Executed | Example |
|------|--------|---------------|---------|
| Before | `run_once_before_` | Before other scripts, once when changed | `run_once_before_001-requirements.sh` |
| Setup | `run_once_setup_` | Main setup phase, once when changed | `run_once_setup_100-base.sh` |
| Once | `run_once_` | Additional setup, once when changed | `run_once_200-packages.sh` |
| After | `run_after_` | After all scripts, every time | `run_after_900-link-bash.sh` |
| On Change | `run_onchange_` | When file content changes | `run_onchange_install-packages.sh` |

### User Scripts

Located in `~/.local/bin/`:

- Helper utilities
- System management tools
- Development shortcuts

## Core Setup Scripts

### Prerequisites

**`run_once_before_001-base-requirements.sh.tmpl`**
```bash
#!/usr/bin/env bash
# Ensure base requirements are met

set -euo pipefail

# Check for required commands
for cmd in git curl wget; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: $cmd is required but not installed" >&2
        exit 1
    fi
done

# Create required directories
mkdir -p ~/.local/{bin,lib,share,state}
mkdir -p ~/.config
mkdir -p ~/.cache
```

**`run_once_before_010-detect-system.sh.tmpl`**
```bash
#!/usr/bin/env bash
# Detect system characteristics

# Export for use in other scripts
export IS_UBUNTU={{ .isUbuntu }}
export IS_ALMALINUX={{ .isAlmaLinux }}
export IS_WSL={{ .isWSL }}
export IS_DOCKER={{ .isDocker }}
```

### Package Installation

**`run_once_setup_200-os-packages.sh.tmpl`**
```bash
#!/usr/bin/env bash
# Install OS-specific packages

set -euo pipefail
. ~/.local/lib/logger/core.bash

logger:info "Installing OS packages"

{{- if .isUbuntu }}
# Ubuntu packages
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

{{- else if .isAlmaLinux }}
# AlmaLinux packages
sudo yum groupinstall -y "Development Tools"
sudo yum install -y \
    epel-release \
    wget \
    curl \
    git
{{- end }}

logger:success "OS packages installed"
```

**`run_once_setup_300-homebrew.sh.tmpl`**
```bash
#!/usr/bin/env bash
# Install and configure Homebrew

set -euo pipefail
. ~/.local/lib/logger/core.bash

if ! command -v brew &> /dev/null; then
    logger:info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add to PATH based on system
{{- if eq .chezmoi.arch "arm64" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- else }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- end }}

# Install from Brewfile
if [[ -f ~/.config/homebrew/Brewfile ]]; then
    logger:info "Installing Homebrew packages"
    brew bundle --file=~/.config/homebrew/Brewfile
fi
```

### Configuration Scripts

**`run_after_900-link-bash.sh.tmpl`**
```bash
#!/usr/bin/env bash
# Link bash modules

set -euo pipefail
. ~/.local/lib/logger/core.bash

logger:info "Linking bash modules"

# Default modules to enable
MODULES=(
    "000-environment"
    "100-path"
    "200-aliases"
    "300-functions"
    "400-prompt"
    "500-completion"
)

# Additional modules based on system
{{- if .isDesktop }}
MODULES+=("600-desktop")
{{- end }}

{{- if .isServer }}
MODULES+=("700-server")
{{- end }}

# Create symlinks
for module in "${MODULES[@]}"; do
    for file in ~/.bashrc.avail/${module}*.bash; do
        if [[ -f "$file" ]]; then
            ln -sf "$file" ~/.bashrc.d/
            logger:success "Enabled: $(basename "$file")"
        fi
    done
done
```

## Helper Scripts

### Debian Repository Management

**`~/.local/bin/deb-repo-init.sh`**
```bash
#!/usr/bin/env bash
# Initialize local Debian repository

set -euo pipefail

REPO_DIR="$HOME/.local/share/deb-repo"
GPG_KEY="local-repo"

# Create repository structure
mkdir -p "$REPO_DIR"/{pool,dists/stable/main/binary-amd64}

# Generate GPG key if needed
if ! gpg --list-keys "$GPG_KEY" &>/dev/null; then
    gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Local Repository
Name-Email: repo@localhost
Expire-Date: 0
%no-protection
%commit
EOF
fi

# Create repository configuration
cat > "$REPO_DIR/apt-ftparchive.conf" <<EOF
Dir {
    ArchiveDir "$REPO_DIR";
};

Default {
    Packages::Compress ". gzip bzip2";
    Contents::Compress ". gzip bzip2";
};

BinDirectory "pool" {
    Packages "dists/stable/main/binary-amd64/Packages";
    Contents "dists/stable/Contents-amd64";
};
EOF

echo "Repository initialized at: $REPO_DIR"
```

**`~/.local/bin/deb-repo-add.sh`**
```bash
#!/usr/bin/env bash
# Add package to local repository

set -euo pipefail

REPO_DIR="$HOME/.local/share/deb-repo"
PACKAGE="${1:?Usage: $0 <package.deb|url>}"

# Download if URL
if [[ "$PACKAGE" =~ ^https?:// ]]; then
    TEMP_FILE=$(mktemp)
    wget -O "$TEMP_FILE" "$PACKAGE"
    PACKAGE="$TEMP_FILE"
fi

# Copy to pool
cp "$PACKAGE" "$REPO_DIR/pool/"

# Update repository
(
    cd "$REPO_DIR"
    apt-ftparchive generate apt-ftparchive.conf
    apt-ftparchive release dists/stable > dists/stable/Release
    gpg --default-key "local-repo" -abs -o dists/stable/Release.gpg dists/stable/Release
)

echo "Package added to repository"
echo "Run 'sudo apt update' to refresh package list"
```

### Development Utilities

**`~/.local/bin/realm-create.sh`**
```bash
#!/usr/bin/env bash
# Create a new development realm

set -euo pipefail
. ~/.local/lib/logger/core.bash

realm_create() {
    local domain="${1:?Usage: realm_create <domain> <project>}"
    local project="${2:?Usage: realm_create <domain> <project>}"
    
    # Convert domain to path
    local realm_path="$HOME/realms/$(echo "$domain" | tr '.' '/')/$project"
    
    if [[ -d "$realm_path" ]]; then
        logger:error "Realm already exists: $realm_path"
        return 1
    fi
    
    # Create realm
    mkdir -p "$realm_path"
    cd "$realm_path"
    
    # Initialize git
    git init
    
    # Create basic structure
    mkdir -p {src,tests,docs,scripts}
    
    # Create README
    cat > README.md <<EOF
# $project

## Overview

Project created in realm: $domain/$project

## Setup

\`\`\`bash
cd $(pwd)
direnv allow
\`\`\`

## Development

TODO: Add development instructions
EOF

    # Create .envrc
    cat > .envrc <<EOF
export PROJECT_NAME="$project"
export PROJECT_ROOT="\$(pwd)"

# Add project bin to PATH
PATH_add bin
PATH_add scripts

# Load local environment if exists
source_env_if_exists .env.local
EOF

    # Create .gitignore
    cat > .gitignore <<EOF
# Environment
.env
.env.local
.envrc.local

# Dependencies
node_modules/
vendor/
.venv/

# Build artifacts
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

    logger:success "Created realm: $realm_path"
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    realm_create "$@"
fi
```

**`~/.local/bin/git-cleanup.sh`**
```bash
#!/usr/bin/env bash
# Clean up git branches and remotes

set -euo pipefail
. ~/.local/lib/logger/core.bash

git_cleanup() {
    logger:info "Cleaning up git repository"
    
    # Fetch and prune remotes
    logger:info "Pruning remote branches"
    git fetch --all --prune
    
    # Delete merged branches
    logger:info "Deleting merged branches"
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d 2>/dev/null || true
    
    # Clean up gone branches
    logger:info "Removing gone branches"
    git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | \
        awk '$2 == "[gone]" {print $1}' | \
        xargs -n 1 git branch -D 2>/dev/null || true
    
    # Garbage collection
    logger:info "Running garbage collection"
    git gc --aggressive --prune=now
    
    logger:success "Git cleanup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_cleanup
fi
```

### System Maintenance

**`~/.local/bin/system-update.sh`**
```bash
#!/usr/bin/env bash
# Update entire system

set -euo pipefail
. ~/.local/lib/logger/core.bash

logger:info "Starting system update"

# Update chezmoi
logger:info "Updating dotfiles"
chezmoi update

# Update OS packages
{{- if .isUbuntu }}
logger:info "Updating APT packages"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
{{- else if .isAlmaLinux }}
logger:info "Updating YUM packages"
sudo yum update -y
{{- end }}

# Update Homebrew
if command -v brew &>/dev/null; then
    logger:info "Updating Homebrew"
    brew update && brew upgrade
    brew cleanup -s
fi

# Update language packages
if command -v pip &>/dev/null; then
    logger:info "Updating pip"
    pip install --upgrade pip
fi

if command -v npm &>/dev/null; then
    logger:info "Updating npm"
    npm update -g
fi

logger:success "System update complete"
```

**`~/.local/bin/backup-configs.sh`**
```bash
#!/usr/bin/env bash
# Backup configuration files

set -euo pipefail
. ~/.local/lib/logger/core.bash

BACKUP_DIR="$HOME/backups/configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

backup_configs() {
    logger:info "Starting configuration backup"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Define what to backup
    local -a items=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.local/lib"
        "$HOME/.bashrc"
        "$HOME/.bashrc.d"
        "$HOME/.gitconfig"
        "$HOME/.ssh/config"
    )
    
    # Create archive
    local backup_file="$BACKUP_DIR/config_${TIMESTAMP}.tar.gz"
    
    tar -czf "$backup_file" \
        --exclude="*.log" \
        --exclude="*.cache" \
        --exclude="*/__pycache__" \
        "${items[@]}" 2>/dev/null || true
    
    logger:success "Backup created: $backup_file"
    
    # Cleanup old backups (keep last 10)
    ls -t "$BACKUP_DIR"/config_*.tar.gz | tail -n +11 | xargs rm -f 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    backup_configs
fi
```

## Script Templates

### Basic Script Template

```bash
#!/usr/bin/env bash
# Description of what this script does

set -euo pipefail

# Source libraries
. ~/.local/lib/logger/core.bash
. ~/.local/lib/common/core.bash

# Initialize
logger:init

# Constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions
main() {
    local arg="${1:-}"
    
    logger:info "Starting $SCRIPT_NAME"
    
    # Main logic here
    
    logger:success "Completed successfully"
}

# Show usage
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [options] <arguments>

Description:
    Brief description of what this script does

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug mode

Examples:
    $SCRIPT_NAME arg1 arg2
    $SCRIPT_NAME --verbose

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            export LOG_LEVEL="DEBUG"
            shift
            ;;
        -d|--debug)
            set -x
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            logger:error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Interactive Script Template

```bash
#!/usr/bin/env bash
# Interactive script template

set -euo pipefail
. ~/.local/lib/logger/core.bash

# Colors for interactive output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Prompt functions
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    
    local yn
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
        yn="y"
    else
        prompt="$prompt [y/N] "
        yn="n"
    fi
    
    read -rp "$prompt" yn
    yn="${yn:-$default}"
    
    [[ "$yn" =~ ^[Yy] ]]
}

select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo "$prompt"
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            return 0
        fi
    done
}

# Main interactive flow
main() {
    echo -e "${BLUE}Welcome to the Interactive Setup${NC}"
    echo
    
    if confirm "Do you want to proceed?" "y"; then
        local choice=$(select_option "Choose an option:" "Option 1" "Option 2" "Option 3")
        echo -e "${GREEN}You selected: $choice${NC}"
    else
        echo -e "${YELLOW}Cancelled by user${NC}"
        exit 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Best Practices

### Error Handling

```bash
# Use strict mode
set -euo pipefail

# Trap errors
trap 'echo "Error on line $LINENO"' ERR

# Check command success
if ! command_that_might_fail; then
    logger:error "Command failed"
    exit 1
fi

# Use || for fallbacks
value=$(get_value) || value="default"
```

### Logging

```bash
# Always use logger for user-facing output
logger:info "Starting process"
logger:success "Process completed"
logger:warning "This might cause issues"
logger:error "Process failed"
logger:debug "Debug information"

# Use different log levels
export LOG_LEVEL="DEBUG" # Show all messages
export LOG_LEVEL="INFO"  # Default
export LOG_LEVEL="ERROR" # Only errors
```

### Portability

```bash
# Check for commands before using
if command -v docker &>/dev/null; then
    # Docker-specific code
fi

# Use portable constructs
# Good
if [[ -f "$file" ]]; then

# Avoid
if [ -f "$file" ]; then

# Handle different systems
case "$(uname -s)" in
    Linux)
        # Linux-specific
        ;;
    Darwin)
        # macOS-specific
        ;;
esac
```

### Security

```bash
# Quote all variables
file="$1"
rm -f "$file"  # Not: rm -f $file

# Use -- to separate options from arguments
grep -- "$pattern" "$file"

# Validate input
if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    logger:error "Invalid input"
    exit 1
fi

# Don't store secrets in scripts
API_KEY="${API_KEY:?API_KEY environment variable required}"
```