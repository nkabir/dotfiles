# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository that automates development environment setup across Ubuntu and AlmaLinux distributions. The repository uses chezmoi's template system extensively for OS-specific configurations.

## Common Commands

### Chezmoi Operations
```bash
# Apply changes to the system
chezmoi apply

# View what changes would be made
chezmoi diff

# Update from repository and apply
chezmoi update

# Edit a file and apply changes
chezmoi edit ~/.bashrc
chezmoi apply

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config

# Execute chezmoi scripts manually
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Local Repository Management
```bash
# Add a .deb package to local repository
~/.local/bin/deb-repo-add.sh package.deb

# Add package from URL
~/.local/bin/deb-repo-add.sh https://example.com/package.deb

# Initialize local Debian repository
~/.local/bin/deb-repo-init.sh
```

## Architecture

### Directory Structure
- `blackbox/` - Main chezmoi source directory (set as root via `.chezmoiroot`)
- `dot_*` directories become dotfiles in home (e.g., `dot_bashrc.avail/` → `~/.bashrc.avail/`)
- `dot_scripts/` - Chezmoi execution scripts organized in subdirectories:
  - `before/` - Pre-installation scripts (e.g., `run_before_100-sudo.sh.tmpl`)
  - `setup/` - One-time setup scripts (e.g., `run_once_100-setup-bash.sh.tmpl`)
  - `after/` - Post-installation scripts (e.g., `run_after_900-link-bash.sh.tmpl`)
- Scripts are numbered (e.g., `100-`, `200-`, `900-`) to control execution order
- `repos/` - Repository structure templates (replaces previous "realms" concept)
- `common/` - Python utilities for system detection and shared functions
- `docs/` - MkDocs-based comprehensive documentation

### Key Components

1. **Modular Bash System**
   - Modules in `blackbox/dot_bashrc.avail/` (12 modules) deploy to `~/.bashrc.avail/`
   - Active modules are symlinked to `~/.bashrc.d/` at runtime
   - Modules auto-activate via `dot_scripts/after/run_after_900-link-bash.sh.tmpl`
   - Module naming: `NNN-name.bash.tmpl` (e.g., `100-bash.bash.tmpl`, `900-python.bash.tmpl`)

2. **Template System**
   - All `.tmpl` files are processed by chezmoi
   - Access user data via `.emailFree`, `.emailCorp`, `.githubId`, `.homeRealm`
   - OS detection via `.isUbuntu`, `.isAlmaLinux` boolean flags

3. **Library System** (`dot_local/lib/`)
   - `logger/core.bash`: Logging with color support and multiple targets
   - `bitwarden/core.bash`: Secret management integration
   - `gum/core.bash`: Terminal UI utilities
   - `rage/core.bash`: Encryption utilities
   - `shinfo/core.bash`: System information
   - `skate/core.bash`: Terminal tools
   - Libraries are sourced via `. ~/.local/lib/[name]/core.bash`

4. **Package Management**
   - OS packages: Conditional installation based on distribution
   - Homebrew: Cross-platform package manager for development tools
   - Local repositories: Custom .deb and pip package hosting

5. **Repos Structure**
   - Development projects organized under `~/repos/`
   - Structure: `~/repos/[reverse.domain]/[project]`
   - Supported domains: `com.github/`, `com.gitlab/`, `org.bitbucket/`, `org.sourcehut/`
   - Each repository can have its own `.envrc` for direnv integration
   - Base templates in `blackbox/repos/` with per-domain configurations

### Development Patterns

1. **Adding a New Bash Module**
   - Create file in `blackbox/dot_bashrc.avail/` with pattern `NNN-name.bash.tmpl`
   - Numbering convention: `000-999` (100s for core, 200s for tools, 300s for languages, 900s for late-init)
   - Use chezmoi templates for conditional logic
   - Module auto-activates after `chezmoi apply` via linking script

2. **OS-Specific Logic**
   ```bash
   {{- if .isUbuntu }}
   # Ubuntu-specific code
   {{- else if .isAlmaLinux }}
   # AlmaLinux-specific code
   {{- end }}
   ```

3. **Using the Logger Library**
   ```bash
   . ~/.local/lib/logger/core.bash
   logger:init
   logger:info "Installation starting"
   logger:error "Failed to install package"
   ```

4. **Script Naming Conventions**
   - `dot_scripts/before/run_before_NNN-*.sh.tmpl`: Pre-installation prerequisites (e.g., sudo setup)
   - `dot_scripts/setup/run_once_NNN-*.sh.tmpl`: One-time setup tasks (e.g., package installation)
   - `dot_scripts/after/run_after_NNN-*.sh.tmpl`: Post-installation hooks (e.g., bash linking, permissions)
   - Numbering: `100` (early), `200-700` (middle), `900-999` (late/cleanup)

### Important Notes

- Always use `.tmpl` extension for files that need processing
- Test changes with `chezmoi diff` before applying
- `dot_scripts/` contains chezmoi execution scripts organized by phase (before/setup/after)
- Development utilities are in `dot_local/bin/` (e.g., `dev-*.sh.tmpl`, `deb-repo-*.sh.tmpl`)
- The `common/` directory contains shared Python utilities for system detection
- Local modifications should be made through chezmoi, not directly to deployed files
- Recent migration: "realms" terminology replaced with "repos" (see `~/repos/` structure)