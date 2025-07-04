# Realms Structure

The Realms system provides an organized approach to managing development projects using reverse domain notation for clear namespace separation.

## Overview

Realms organize projects under `~/realms/` using a hierarchical structure based on reverse domain notation. This approach prevents naming conflicts and provides clear project organization.

## Directory Structure

```
~/realms/
├── com/
│   ├── github/
│   │   ├── myproject/
│   │   ├── another-project/
│   │   └── client-work/
│   ├── gitlab/
│   │   └── internal-tool/
│   └── example/
│       └── demo-app/
├── org/
│   ├── opensource/
│   │   └── contribution/
│   └── nonprofit/
│       └── website/
└── io/
    └── myapp/
        └── backend/
```

## Creating Realms

### Manual Creation

```bash
# Create a realm for a GitHub project
mkdir -p ~/realms/com/github/myproject
cd ~/realms/com/github/myproject

# Initialize git repository
git init
git remote add origin git@github.com:username/myproject.git
```

### Using Helper Script

Create `~/.local/bin/realm-create.sh`:

```bash
#!/bin/bash
# Create a new realm

realm_create() {
    local domain="${1:?Usage: realm_create <domain> <project>}"
    local project="${2:?Usage: realm_create <domain> <project>}"
    
    # Parse domain into path
    local realm_path="$HOME/realms/$(echo "$domain" | tr '.' '/')/$project"
    
    # Create directory
    mkdir -p "$realm_path"
    
    # Initialize project
    cd "$realm_path" || return 1
    
    echo "Created realm: $realm_path"
}

# Usage
realm_create "com.github" "myproject"
```

## Configuration

### Environment Variables

Each realm can have its own environment configuration using `direnv`:

**`~/realms/com/github/myproject/.envrc`:**
```bash
# Project-specific environment
export PROJECT_NAME="myproject"
export NODE_ENV="development"
export DATABASE_URL="postgresql://localhost/myproject_dev"

# Use specific tool versions
use asdf

# Load project secrets
source_env_if_exists .env.local

# Add project bin to PATH
PATH_add bin
PATH_add node_modules/.bin
```

### Git Configuration

Use conditional includes for realm-specific Git config:

**`~/.gitconfig`:**
```gitconfig
# Personal projects
[includeIf "gitdir:~/realms/com/github/"]
    path = ~/.gitconfig.github

# Work projects  
[includeIf "gitdir:~/realms/com/company/"]
    path = ~/.gitconfig.work

# Open source contributions
[includeIf "gitdir:~/realms/org/"]
    path = ~/.gitconfig.opensource
```

**`~/.gitconfig.github`:**
```gitconfig
[user]
    email = personal@example.com
    signingkey = PERSONAL_GPG_KEY

[github]
    user = mygithubusername
```

## Project Templates

### Web Application Template

```bash
# Create realm
mkdir -p ~/realms/com/github/webapp
cd ~/realms/com/github/webapp

# Initialize project structure
cat > .envrc << 'EOF'
export PROJECT_NAME="webapp"
export NODE_VERSION="18.17.0"
export PYTHON_VERSION="3.11.4"

use asdf

layout_node
layout_python

PATH_add bin
EOF

# Create standard directories
mkdir -p {src,tests,docs,config,scripts}

# Create README
cat > README.md << 'EOF'
# WebApp

## Development Setup

1. Install dependencies:
   ```bash
   direnv allow
   npm install
   pip install -r requirements.txt
   ```

2. Run development server:
   ```bash
   npm run dev
   ```
EOF
```

### CLI Tool Template

```bash
# Create realm  
mkdir -p ~/realms/com/github/cli-tool
cd ~/realms/com/github/cli-tool

# Go project structure
cat > .envrc << 'EOF'
export GO111MODULE=on
export GOPATH="$PWD/.go"
export PATH="$GOPATH/bin:$PATH"

# Project-specific
export PROJECT_NAME="cli-tool"
EOF

# Initialize Go module
go mod init github.com/username/cli-tool
```

## Realm Management

### Listing Realms

```bash
# List all realms
find ~/realms -type d -name .git -prune | \
    sed 's|/.git||' | \
    sed "s|$HOME/realms/||" | \
    sort

# Create an alias
alias realms='find ~/realms -type d -name .git -prune | sed "s|/.git||" | sed "s|$HOME/realms/||" | sort'
```

### Quick Navigation

Add to `~/.bashrc.d/500-realms.bash`:

```bash
# Realm navigation function
r() {
    local realm="${1:?Usage: r <realm-path>}"
    local full_path="$HOME/realms/$realm"
    
    if [[ -d "$full_path" ]]; then
        cd "$full_path" || return 1
    else
        echo "Realm not found: $realm" >&2
        echo "Available realms:" >&2
        realms >&2
        return 1
    fi
}

# Completion for realm navigation
_r_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local realms=$(find ~/realms -type d -name .git -prune 2>/dev/null | \
        sed "s|$HOME/realms/||" | \
        sed 's|/.git||' | \
        sort)
    
    COMPREPLY=($(compgen -W "$realms" -- "$cur"))
}
complete -F _r_complete r
```

### Realm Status

Check status of all realms:

```bash
#!/bin/bash
# ~/.local/bin/realm-status.sh

realm_status() {
    echo "Checking realm status..."
    echo
    
    find ~/realms -type d -name .git -prune | while read -r git_dir; do
        local realm_dir="${git_dir%/.git}"
        local realm_path="${realm_dir#$HOME/realms/}"
        
        pushd "$realm_dir" > /dev/null || continue
        
        # Check git status
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            echo "● $realm_path - uncommitted changes"
        elif [[ -n $(git log @{u}.. 2>/dev/null) ]]; then
            echo "● $realm_path - unpushed commits"
        else
            echo "✓ $realm_path"
        fi
        
        popd > /dev/null || continue
    done
}
```

## Integration with Tools

### VS Code

Configure workspace settings per realm:

**`~/realms/com/github/project/.vscode/settings.json`:**
```json
{
    "editor.formatOnSave": true,
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
    "typescript.tsdk": "${workspaceFolder}/node_modules/typescript/lib",
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/__pycache__": true
    }
}
```

### Docker

Realm-specific Docker setup:

**`~/realms/com/github/webapp/docker-compose.yml`:**
```yaml
version: '3.8'

services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - PROJECT_NAME=${PROJECT_NAME}
      - NODE_ENV=${NODE_ENV:-development}
    ports:
      - "3000:3000"
      
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=${PROJECT_NAME}_dev
      - POSTGRES_PASSWORD=development
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Backup Strategy

Automated realm backup:

```bash
#!/bin/bash
# ~/.local/bin/realm-backup.sh

BACKUP_DIR="$HOME/backups/realms"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

realm_backup() {
    local realm="${1:?Usage: realm_backup <realm-path>}"
    local realm_dir="$HOME/realms/$realm"
    
    if [[ ! -d "$realm_dir" ]]; then
        echo "Realm not found: $realm" >&2
        return 1
    fi
    
    local backup_name="${realm//\//_}_${TIMESTAMP}.tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p "$BACKUP_DIR"
    
    # Create backup excluding common directories
    tar -czf "$backup_path" \
        --exclude=node_modules \
        --exclude=.venv \
        --exclude=.go \
        --exclude=target \
        --exclude=dist \
        -C "$HOME/realms" \
        "$realm"
    
    echo "Backup created: $backup_path"
}

# Backup all realms
realm_backup_all() {
    find ~/realms -type d -name .git -prune | while read -r git_dir; do
        local realm_dir="${git_dir%/.git}"
        local realm_path="${realm_dir#$HOME/realms/}"
        realm_backup "$realm_path"
    done
}
```

## Best Practices

### 1. Consistent Naming

Use lowercase with hyphens:
- ✓ `my-awesome-project`
- ✗ `MyAwesomeProject`
- ✗ `my_awesome_project`

### 2. Domain Organization

Choose appropriate top-level domains:
- `com/` - Commercial projects
- `org/` - Open source/non-profit
- `io/` - Tech/app projects
- `net/` - Network services

### 3. Environment Isolation

Always use virtual environments:
```bash
# Python
python -m venv .venv
source .venv/bin/activate

# Node.js
echo "node_modules/" >> .gitignore
npm install

# Ruby
bundle install --path vendor/bundle
```

### 4. Documentation

Every realm should have:
- `README.md` - Project overview and setup
- `.envrc.example` - Example environment configuration
- `docs/` - Detailed documentation

### 5. Secrets Management

Never commit secrets:
```bash
# Good: Use environment variables
export API_KEY="${API_KEY:?API_KEY not set}"

# Good: Use secret files (git-ignored)
source .env.local

# Bad: Hardcoded secrets
API_KEY="sk-1234567890abcdef"
```

## Advanced Usage

### Multi-Realm Projects

Link related realms:

```bash
# Main project
~/realms/com/github/myapp/

# Subprojects as git submodules
~/realms/com/github/myapp/frontend/  # -> submodule
~/realms/com/github/myapp/backend/   # -> submodule
~/realms/com/github/myapp/mobile/    # -> submodule
```

### Realm Templates

Create realm templates:

```bash
# ~/.local/share/realm-templates/webapp/
├── .envrc
├── .gitignore
├── README.md
├── package.json
├── docker-compose.yml
└── Makefile

# Initialize from template
cp -r ~/.local/share/realm-templates/webapp/* ~/realms/com/github/newproject/
```

### CI/CD Integration

GitHub Actions for realms:

**`.github/workflows/ci.yml`:**
```yaml
name: CI

on: [push, pull_request]

env:
  PROJECT_NAME: ${{ github.event.repository.name }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up environment
        run: |
          echo "Setting up realm environment"
          # Realm-specific setup
```