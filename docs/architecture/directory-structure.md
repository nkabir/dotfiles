# Directory Structure

CWIQ Seed follows a specific directory structure to organize dotfiles and scripts effectively.

## Repository Structure

```
.
├── blackbox/                    # Chezmoi root directory (via .chezmoiroot)
│   ├── dot_bashrc.avail/       # Available bash modules
│   ├── dot_bashrc.d/           # Active bash modules (symlinked)
│   ├── dot_config/             # ~/.config directory contents
│   ├── dot_local/              # ~/.local directory contents
│   │   ├── bin/               # User scripts and executables
│   │   └── lib/               # Bash/shell libraries
│   ├── dot_scripts/            # Chezmoi execution scripts
│   │   ├── after/             # Post-installation scripts
│   │   ├── before/            # Pre-installation scripts
│   │   └── setup/             # Main setup scripts
│   └── CLAUDE.md              # AI assistant instructions
├── common/                     # Shared Python utilities
├── docs/                       # Documentation source
├── scripts/                    # Development/maintenance scripts
└── mkdocs.yml                  # Documentation configuration
```

## Home Directory Layout

After applying chezmoi, your home directory will contain:

```
~/
├── .bashrc                     # Main bash configuration
├── .bashrc.avail/             # Available bash modules
├── .bashrc.d/                 # Active bash modules
├── .config/                   # XDG config directory
│   ├── chezmoi/              # Chezmoi configuration
│   ├── fontconfig/           # Font configuration
│   └── ...                   # Other app configs
├── .local/                    # User-specific data
│   ├── bin/                  # User executables
│   ├── lib/                  # Shell libraries
│   ├── share/                # Application data
│   └── state/                # Application state
├── .scripts/                  # Utility scripts
└── realms/                    # Development projects

```

## Key Directories

### Bash Configuration

**`.bashrc.avail/`**
- Contains all available bash modules
- Modules follow naming: `XXX-name.bash`
- Not automatically loaded

**`.bashrc.d/`**
- Contains active bash modules
- Symlinks to files in `.bashrc.avail/`
- Automatically sourced by `.bashrc`

### Libraries

**`.local/lib/`**
- Reusable bash/shell libraries
- Each library in its own directory
- Main entry point: `core.bash`

Example structure:
```
~/.local/lib/
├── logger/
│   └── core.bash
├── bitwarden/
│   └── core.bash
└── common/
    └── core.bash
```

### Scripts

**`.local/bin/`**
- User-specific executables
- Added to PATH automatically
- Contains helper scripts like:
  - `deb-repo-add.sh`
  - `deb-repo-init.sh`

**`.scripts/`**
- Development and maintenance scripts
- Not in PATH by default
- Used for one-off operations

### Chezmoi Scripts

**Execution Order:**
1. `run_once_before_*` - Prerequisites
2. `run_once_setup_*` - Main setup
3. `run_once_*` - Additional setup
4. `run_after_*` - Post-setup hooks

**Naming Convention:**
- `XXX-` prefix for ordering (e.g., `001-`, `200-`)
- Lower numbers execute first
- `.tmpl` suffix for templated scripts

### Realms

**`~/realms/`**
- Organized by reverse domain notation
- Structure: `~/realms/[reverse.domain]/[project]`
- Example: `~/realms/com.github/myproject`

Each realm can contain:
- `.envrc` - Directory-specific environment
- Project-specific configurations
- Development resources

## File Naming Conventions

### Dotfiles
- `dot_` prefix becomes `.` in home
- `exact_` prefix for exact directory matching
- `private_` prefix for 600 permissions
- `executable_` prefix for executable files

### Templates
- `.tmpl` suffix for chezmoi templates
- Processed during `chezmoi apply`
- Access to user data and functions

### Scripts
- `run_once_` - Runs once when content changes
- `run_onchange_` - Runs when content changes
- `run_after_` - Always runs after other scripts

## Special Files

### Configuration
- `.chezmoiroot` - Specifies root directory
- `.chezmoiignore` - Files to ignore
- `.chezmoidata.yaml` - Additional data

### Documentation
- `CLAUDE.md` - AI assistant context
- `README.md` - Repository documentation

## Environment Variables

Key paths are configured:
- `PATH` includes `~/.local/bin`
- `XDG_CONFIG_HOME` = `~/.config`
- `XDG_DATA_HOME` = `~/.local/share`
- `XDG_STATE_HOME` = `~/.local/state`
- `XDG_CACHE_HOME` = `~/.cache`