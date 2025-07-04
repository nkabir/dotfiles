# Command Reference

This page provides a comprehensive reference for all commands used in the ChezMoi dotfiles system.

## ChezMoi Commands

### Basic Operations

```bash
# Apply configuration changes
chezmoi apply

# Preview changes before applying
chezmoi diff

# Update from repository and apply
chezmoi update

# Edit a file through ChezMoi
chezmoi edit ~/.bashrc

# Add a new file to management
chezmoi add ~/.config/newapp/config

# Remove a file from management
chezmoi forget ~/.config/oldapp/config

# List all managed files
chezmoi managed

# View ChezMoi status
chezmoi status
```

### Advanced Operations

```bash
# Re-run scripts by clearing state
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply

# Apply with verbose output
chezmoi apply -v

# Apply only specific files
chezmoi apply ~/.bashrc

# Edit ChezMoi configuration
chezmoi edit-config

# Initialize from a specific branch
chezmoi init --branch develop --apply https://github.com/user/dotfiles.git

# Execute a template and see output
chezmoi execute-template '{{ .chezmoi.hostname }}'
```

## Package Management

### Local Debian Repository

```bash
# Initialize local .deb repository
~/.local/bin/deb-repo-init.sh

# Add a local .deb package
~/.local/bin/deb-repo-add.sh /path/to/package.deb

# Add a .deb from URL
~/.local/bin/deb-repo-add.sh https://example.com/package.deb

# List packages in local repository
~/.local/bin/deb-repo-list.sh
```

### Local Pip Repository

```bash
# Initialize local pip repository
~/.local/bin/pip-repo-init.sh

# Add a Python package
~/.local/bin/pip-repo-add.sh /path/to/package.whl

# Add package from PyPI
~/.local/bin/pip-repo-add.sh package-name
```

## Development Tools

### Environment Launchers

```bash
# Launch Aider AI assistant
~/.local/bin/dev-aider.sh

# Launch development Chrome instance
~/.local/bin/dev-chrome.sh

# Launch Emacs
~/.local/bin/dev-emacs.sh

# Launch Tilix terminal
~/.local/bin/dev-tilix.sh

# Manage secrets
~/.local/bin/dev-secrets.sh

# Kill development processes
~/.local/bin/dev-kill.sh
```

### Utility Commands

```bash
# Manage Bitwarden cookies
~/.local/bin/bwcookie

# Colored diff output
~/.local/bin/colordiff

# Pretty print PATH
~/.local/bin/path

# System information
~/.local/bin/sysinfo
```

## Bash Module Management

```bash
# List available modules
ls ~/.bashrc.avail/

# List enabled modules
ls ~/.bashrc.d/

# Enable a module (re-run linking script)
chezmoi apply --source-path run_after_900-link-bash.sh.tmpl

# Disable a module
rm ~/.bashrc.d/500-module-name.bash
```

## Library Usage

### Logger Library

```bash
# In your scripts
. ~/.local/lib/logger/core.bash
logger:init
logger:info "Starting process"
logger:warning "Potential issue detected"
logger:error "Operation failed"
logger:success "Task completed"
```

### Bitwarden Library

```bash
# In your scripts
. ~/.local/lib/bitwarden/core.bash
bitwarden:init
bitwarden:get-password "item-name"
bitwarden:get-field "item-name" "field-name"
```

## Environment Variables

### ChezMoi Variables

```bash
# View all ChezMoi data
chezmoi data

# Common variables
$CHEZMOI_SOURCE_DIR    # Source directory
$CHEZMOI_HOSTNAME      # Current hostname
$CHEZMOI_OS            # Operating system
$CHEZMOI_ARCH          # Architecture
```

### Custom Variables

```bash
# Development environment
$REALMS_ROOT           # Base directory for realms
$LOCAL_BIN             # User's local bin directory
$HOMEBREW_PREFIX       # Homebrew installation prefix

# Package repositories
$DEB_REPO_PATH         # Local .deb repository
$PIP_REPO_PATH         # Local pip repository
```

## Troubleshooting Commands

```bash
# Check ChezMoi version
chezmoi --version

# Verify template data
chezmoi data

# Test template rendering
chezmoi execute-template < template-file.tmpl

# Check for errors in verbose mode
chezmoi apply -v --dry-run

# Verify file permissions
chezmoi verify

# Re-init to fix issues
chezmoi init --apply

# Check git status of source
chezmoi git status

# Update ChezMoi itself
chezmoi upgrade
```