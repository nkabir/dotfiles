# Environment Variables

Complete reference for environment variables used in CWIQ Seed dotfiles.

## System Variables

### XDG Base Directory

Following the XDG Base Directory specification:

| Variable | Default Value | Purpose |
|----------|---------------|---------|
| `XDG_CONFIG_HOME` | `~/.config` | User configuration files |
| `XDG_DATA_HOME` | `~/.local/share` | User data files |
| `XDG_STATE_HOME` | `~/.local/state` | User state data |
| `XDG_CACHE_HOME` | `~/.cache` | User cache files |
| `XDG_RUNTIME_DIR` | `/run/user/$UID` | Runtime files |

### Path Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `PATH` | Executable search path | `/usr/local/bin:/usr/bin:/bin` |
| `MANPATH` | Manual page search path | `/usr/local/man:/usr/man` |
| `LD_LIBRARY_PATH` | Shared library path | `/usr/local/lib` |
| `PKG_CONFIG_PATH` | Package config path | `/usr/local/lib/pkgconfig` |

## Development Environment

### Programming Languages

**Python:**
| Variable | Purpose | Example |
|----------|---------|---------|
| `PYTHONPATH` | Module search path | `~/lib/python` |
| `PYTHONUSERBASE` | User install base | `~/.local` |
| `VIRTUAL_ENV` | Active virtualenv | `~/envs/myproject` |
| `PIP_CACHE_DIR` | Pip cache location | `~/.cache/pip` |
| `PIPENV_VENV_IN_PROJECT` | Keep venv in project | `1` |

**Node.js:**
| Variable | Purpose | Example |
|----------|---------|---------|
| `NODE_PATH` | Module search path | `~/.local/lib/node_modules` |
| `NPM_CONFIG_PREFIX` | npm global prefix | `~/.local` |
| `NVM_DIR` | nvm installation | `~/.nvm` |
| `NODE_ENV` | Node environment | `development` |

**Go:**
| Variable | Purpose | Example |
|----------|---------|---------|
| `GOPATH` | Go workspace | `~/go` |
| `GOBIN` | Go binaries | `~/go/bin` |
| `GO111MODULE` | Module mode | `on` |
| `GOPROXY` | Module proxy | `https://proxy.golang.org` |

**Ruby:**
| Variable | Purpose | Example |
|----------|---------|---------|
| `GEM_HOME` | Gem installation | `~/.local/share/gem` |
| `GEM_PATH` | Gem search path | `~/.local/share/gem` |
| `BUNDLE_PATH` | Bundle install path | `vendor/bundle` |

### Build Tools

| Variable | Purpose | Example |
|----------|---------|---------|
| `CC` | C compiler | `gcc` |
| `CXX` | C++ compiler | `g++` |
| `CFLAGS` | C compiler flags | `-O2 -pipe` |
| `CXXFLAGS` | C++ compiler flags | `-O2 -pipe` |
| `LDFLAGS` | Linker flags | `-L/usr/local/lib` |
| `MAKEFLAGS` | Make options | `-j4` |

## Application Settings

### Editor Configuration

| Variable | Purpose | Example |
|----------|---------|---------|
| `EDITOR` | Default text editor | `vim` |
| `VISUAL` | Visual editor | `code` |
| `SUDO_EDITOR` | Editor for sudo | `vim` |
| `GIT_EDITOR` | Git commit editor | `vim` |

### Terminal Settings

| Variable | Purpose | Example |
|----------|---------|---------|
| `TERM` | Terminal type | `xterm-256color` |
| `COLORTERM` | Color terminal | `truecolor` |
| `LANG` | System locale | `en_US.UTF-8` |
| `LC_ALL` | Override locale | `en_US.UTF-8` |
| `TZ` | Timezone | `America/New_York` |

### Pager Configuration

| Variable | Purpose | Example |
|----------|---------|---------|
| `PAGER` | Default pager | `less` |
| `LESS` | Less options | `-FRSX` |
| `LESSCHARSET` | Less charset | `utf-8` |
| `LESS_TERMCAP_*` | Less colors | See below |

**Less Color Configuration:**
```bash
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin standout
export LESS_TERMCAP_se=$'\E[0m'        # reset standout
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
```

## CWIQ Seed Specific

### System Detection

Set automatically by detection scripts:

| Variable | Type | Description |
|----------|------|-------------|
| `IS_UBUNTU` | boolean | Running on Ubuntu |
| `IS_ALMALINUX` | boolean | Running on AlmaLinux |
| `IS_WSL` | boolean | Running in WSL |
| `IS_DOCKER` | boolean | Running in Docker |
| `IS_DESKTOP` | boolean | Desktop environment present |
| `IS_SERVER` | boolean | Server environment |

### Configuration Paths

| Variable | Purpose | Default |
|----------|---------|---------|
| `CWIQ_ROOT` | CWIQ installation | `~/.local/share/chezmoi` |
| `CWIQ_CONFIG` | Configuration directory | `~/.config/cwiq` |
| `CWIQ_DATA` | Data directory | `~/.local/share/cwiq` |
| `CWIQ_CACHE` | Cache directory | `~/.cache/cwiq` |

### Feature Flags

| Variable | Purpose | Values |
|----------|---------|--------|
| `CWIQ_COLORS` | Enable colors | `true`/`false` |
| `CWIQ_DEBUG` | Debug mode | `true`/`false` |
| `CWIQ_VERBOSE` | Verbose output | `true`/`false` |
| `CWIQ_QUIET` | Quiet mode | `true`/`false` |

## Tool-Specific Variables

### Git

| Variable | Purpose | Example |
|----------|---------|---------|
| `GIT_AUTHOR_NAME` | Commit author | `John Doe` |
| `GIT_AUTHOR_EMAIL` | Author email | `john@example.com` |
| `GIT_COMMITTER_NAME` | Committer name | `John Doe` |
| `GIT_COMMITTER_EMAIL` | Committer email | `john@example.com` |
| `GIT_SSH_COMMAND` | SSH command | `ssh -i ~/.ssh/id_rsa` |
| `GIT_MERGE_AUTOEDIT` | Auto-edit merges | `no` |

### Docker

| Variable | Purpose | Example |
|----------|---------|---------|
| `DOCKER_HOST` | Docker daemon | `unix:///var/run/docker.sock` |
| `DOCKER_CONFIG` | Config directory | `~/.docker` |
| `DOCKER_BUILDKIT` | BuildKit enabled | `1` |
| `COMPOSE_PROJECT_NAME` | Compose project | `myapp` |
| `COMPOSE_FILE` | Compose files | `docker-compose.yml` |

### Homebrew

| Variable | Purpose | Example |
|----------|---------|---------|
| `HOMEBREW_PREFIX` | Installation prefix | `/home/linuxbrew/.linuxbrew` |
| `HOMEBREW_CELLAR` | Formula directory | `$HOMEBREW_PREFIX/Cellar` |
| `HOMEBREW_REPOSITORY` | Git repository | `$HOMEBREW_PREFIX/Homebrew` |
| `HOMEBREW_NO_ANALYTICS` | Disable analytics | `1` |
| `HOMEBREW_NO_AUTO_UPDATE` | Disable auto-update | `1` |

### Package Managers

| Variable | Purpose | Example |
|----------|---------|---------|
| `APT_CACHE` | APT cache server | `http://localhost:3142` |
| `PIP_INDEX_URL` | PyPI index | `https://pypi.org/simple` |
| `NPM_REGISTRY` | npm registry | `https://registry.npmjs.org` |
| `CARGO_HOME` | Cargo directory | `~/.cargo` |

## Security Variables

### Authentication

| Variable | Purpose | Security Level |
|----------|---------|----------------|
| `BW_SESSION` | Bitwarden session | Sensitive |
| `GITHUB_TOKEN` | GitHub API token | Sensitive |
| `GITLAB_TOKEN` | GitLab API token | Sensitive |
| `SSH_AUTH_SOCK` | SSH agent socket | Runtime |
| `GPG_TTY` | GPG terminal | Runtime |

### Proxy Settings

| Variable | Purpose | Example |
|----------|---------|---------|
| `HTTP_PROXY` | HTTP proxy | `http://proxy:8080` |
| `HTTPS_PROXY` | HTTPS proxy | `http://proxy:8080` |
| `NO_PROXY` | Bypass proxy | `localhost,127.0.0.1` |
| `ALL_PROXY` | All protocols | `socks5://proxy:1080` |

## Custom Functions

### Environment Helpers

```bash
# Check if variable is set
is_set() {
    local var="$1"
    [[ -n "${!var:-}" ]]
}

# Set default value
set_default() {
    local var="$1"
    local default="$2"
    [[ -z "${!var:-}" ]] && export "$var=$default"
}

# Append to PATH-like variable
path_append() {
    local var="$1"
    local path="$2"
    if [[ -d "$path" ]] && [[ ":${!var}:" != *":$path:"* ]]; then
        export "$var=${!var:+${!var}:}$path"
    fi
}

# Prepend to PATH-like variable
path_prepend() {
    local var="$1"
    local path="$2"
    if [[ -d "$path" ]] && [[ ":${!var}:" != *":$path:"* ]]; then
        export "$var=$path${!var:+:${!var}}"
    fi
}
```

### Usage Examples

```bash
# Set defaults
set_default EDITOR "vim"
set_default BROWSER "firefox"
set_default PAGER "less"

# Manage paths
path_prepend PATH "$HOME/.local/bin"
path_append MANPATH "/usr/local/man"

# Conditional exports
is_set VIRTUAL_ENV && export PS1="(venv) $PS1"

# Platform-specific
case "$(uname -s)" in
    Linux)
        export PLATFORM="linux"
        ;;
    Darwin)
        export PLATFORM="macos"
        ;;
esac
```

## Environment Files

### Loading Order

1. `/etc/environment` - System-wide
2. `/etc/profile` - Login shells
3. `~/.profile` - User login
4. `~/.bashrc` - Interactive shells
5. `~/.bashrc.d/*` - Modular configs
6. `.envrc` - Directory-specific (direnv)
7. `.env.local` - Local overrides

### Project-Specific (.envrc)

```bash
# Project environment
export PROJECT_NAME="myapp"
export PROJECT_ROOT="$(pwd)"

# Development settings
export DEBUG="true"
export LOG_LEVEL="debug"
export DATABASE_URL="postgresql://localhost/myapp_dev"

# Tool versions
use asdf
use nvm 18.17.0

# Path modifications
PATH_add bin
PATH_add node_modules/.bin

# Load secrets
source_env_if_exists .env.local
```

### Machine-Specific

Create `~/.env.local` for machine-specific settings:

```bash
# Machine-specific overrides
export CWIQ_THEME="dark"
export GIT_AUTHOR_EMAIL="work@company.com"
export DOCKER_HOST="tcp://docker.local:2376"

# Local paths
export ANDROID_HOME="/opt/android-sdk"
export JAVA_HOME="/usr/lib/jvm/java-11"

# Performance tuning
export MAKEFLAGS="-j$(nproc)"
export CARGO_BUILD_JOBS="$(nproc)"
```

## Best Practices

### 1. Use Namespaces

```bash
# Good: Namespaced
export MYAPP_API_KEY="..."
export MYAPP_DEBUG="true"

# Avoid: Generic names
export API_KEY="..."
export DEBUG="true"
```

### 2. Document Variables

```bash
# MYAPP_TIMEOUT: Request timeout in seconds (default: 30)
export MYAPP_TIMEOUT="${MYAPP_TIMEOUT:-30}"

# MYAPP_RETRIES: Number of retry attempts (default: 3)
export MYAPP_RETRIES="${MYAPP_RETRIES:-3}"
```

### 3. Validate Values

```bash
# Validate numeric
if ! [[ "$MYAPP_PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: MYAPP_PORT must be numeric" >&2
    exit 1
fi

# Validate choices
case "$MYAPP_ENV" in
    dev|test|prod) ;;
    *) echo "ERROR: MYAPP_ENV must be dev|test|prod" >&2; exit 1 ;;
esac
```

### 4. Security

```bash
# Never hardcode secrets
export API_KEY="${API_KEY:?API_KEY not set}"

# Use secure defaults
export MYAPP_SSL_VERIFY="${MYAPP_SSL_VERIFY:-true}"

# Mask sensitive values in logs
[[ -n "$API_KEY" ]] && echo "API_KEY is set (${#API_KEY} chars)"
```

### 5. Platform Independence

```bash
# Use conditional exports
[[ -d "/opt/cuda" ]] && export CUDA_HOME="/opt/cuda"

# Handle missing commands
command -v docker &>/dev/null && export DOCKER_ENABLED="true"

# Cross-platform paths
export TMPDIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
```