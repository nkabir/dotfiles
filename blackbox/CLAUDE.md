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
- `dot_*` directories represent dotfiles in the home directory (e.g., `dot_bashrc.d/` → `~/.bashrc.d/`)
- `run_once_*` scripts execute during chezmoi apply when their content changes
- Scripts are numbered (e.g., `001-`, `200-`) to control execution order

### Key Components

1. **Modular Bash System**
   - Modules in `dot_bashrc.avail/` are available but not active
   - Active modules are symlinked to `~/.bashrc.d/`
   - Enable modules by running `run_after_900-link-bash.sh.tmpl`

2. **Template System**
   - All `.tmpl` files are processed by chezmoi
   - Access user data via `.emailFree`, `.emailCorp`, `.githubId`, `.homeRealm`
   - OS detection via `.isUbuntu`, `.isAlmaLinux` boolean flags

3. **Library System** (`dot_local/lib/`)
   - `logger/core.bash`: Logging with color support and multiple targets
   - `bitwarden/core.bash`: Secret management integration
   - Libraries are sourced via `. ~/.local/lib/[name]/core.bash`

4. **Package Management**
   - OS packages: Conditional installation based on distribution
   - Homebrew: Cross-platform package manager for development tools
   - Local repositories: Custom .deb and pip package hosting

5. **Realms Structure**
   - Development projects organized under `~/realms/`
   - Structure: `~/realms/[reverse.domain]/[project]`
   - Each realm can have its own `.envrc` for direnv

### Development Patterns

1. **Adding a New Bash Module**
   - Create file in `dot_bashrc.avail/` with pattern `XXX-name.bash.tmpl`
   - Use chezmoi templates for conditional logic
   - Module will be available after next `chezmoi apply`

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
   - `run_once_before_*`: Setup prerequisites
   - `run_once_setup_*`: One-time setup tasks
   - `run_once_*`: General installation scripts
   - `run_after_*`: Post-installation hooks

### Important Notes

- Always use `.tmpl` extension for files that need processing
- Test changes with `chezmoi diff` before applying
- Scripts in `dot_scripts/` are development utilities, not chezmoi scripts
- The `common/` directory contains shared Python utilities for system detection
- Local modifications should be made through chezmoi, not directly to deployed files

### Terminal and Font Configuration

- **Emoji Support**: The setup installs Noto Color Emoji fonts on both Ubuntu and AlmaLinux
  - Ubuntu: `fonts-noto-color-emoji` and `fonts-noto-mono`
  - AlmaLinux: `google-noto-color-emoji-fonts` and `google-noto-mono-fonts`
  - Fontconfig is configured to prioritize emoji rendering in `~/.config/fontconfig/conf.d/01-emoji.conf`
  - Restart terminal emulators after installation for emoji support