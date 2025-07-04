# Template System

CWIQ Seed leverages chezmoi's powerful template system for dynamic configuration management across different systems and environments.

## Overview

Templates allow you to:
- Generate different configurations based on OS, hostname, or user data
- Share common configurations while customizing specific parts
- Keep sensitive data out of your repository
- Maintain a single source of truth for multiple environments

## Template Syntax

Chezmoi uses Go's `text/template` syntax with double curly braces:

```bash
# Basic variable substitution
export EMAIL="{{ .email }}"

# Conditional logic
{{- if .isUbuntu }}
alias apt-update="sudo apt update && sudo apt upgrade"
{{- else if .isAlmaLinux }}
alias yum-update="sudo yum update"
{{- end }}
```

## Available Data

### User Data

Defined in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
emailFree = "personal@example.com"
emailCorp = "work@company.com"
githubId = "yourusername"
homeRealm = "com.example"
```

Access in templates:
```bash
git config --global user.email "{{ .emailFree }}"
export GITHUB_USER="{{ .githubId }}"
```

### System Detection

Automatic boolean flags:
- `.isUbuntu` - Running on Ubuntu
- `.isAlmaLinux` - Running on AlmaLinux
- `.chezmoi.hostname` - System hostname
- `.chezmoi.os` - Operating system
- `.chezmoi.arch` - System architecture

Example:
```bash
{{- if .isUbuntu }}
export DISTRO="ubuntu"
{{- else if .isAlmaLinux }}
export DISTRO="almalinux"
{{- end }}
```

## Template Functions

### Built-in Functions

**String manipulation:**
```bash
# Convert to uppercase
export PATH_UPPER="{{ .path | upper }}"

# String contains
{{- if contains "work" .chezmoi.hostname }}
source ~/.bashrc.work
{{- end }}
```

**Path operations:**
```bash
# Join paths
export CONFIG_DIR="{{ .chezmoi.homeDir | joinPath ".config" "app" }}"

# Get basename
export SCRIPT_NAME="{{ .scriptPath | base }}"
```

### Custom Functions

**OS Package names:**
```bash
{{- $packages := list }}
{{- if .isUbuntu }}
  {{- $packages = list "build-essential" "curl" "git" }}
{{- else if .isAlmaLinux }}
  {{- $packages = list "gcc" "make" "curl" "git" }}
{{- end }}

{{- range $packages }}
- {{ . }}
{{- end }}
```

## Common Patterns

### OS-Specific Configuration

```bash
# ~/.bashrc.d/100-aliases.bash.tmpl
{{- if .isUbuntu }}
alias ll='ls -alF'
alias update='sudo apt update && sudo apt upgrade'
{{- else if .isAlmaLinux }}
alias ll='ls -al'
alias update='sudo yum update'
{{- end }}
```

### Conditional File Installation

`.chezmoiignore`:
```
{{- if not .isUbuntu }}
.config/ubuntu-only/
{{- end }}

{{- if not .isAlmaLinux }}
.config/alma-only/
{{- end }}
```

### Environment-Based Git Config

```gitconfig
# ~/.gitconfig.tmpl
[user]
    name = "Your Name"
{{- if contains "work" .chezmoi.hostname }}
    email = "{{ .emailCorp }}"
{{- else }}
    email = "{{ .emailFree }}"
{{- end }}
```

### Dynamic Script Generation

```bash
#!/bin/bash
# ~/.local/bin/backup.sh.tmpl

BACKUP_TARGETS=(
    "$HOME/Documents"
    "$HOME/Pictures"
{{- if .includeWorkBackup }}
    "$HOME/work"
{{- end }}
)

BACKUP_DEST="{{ .backupLocation | default "/backup" }}"
```

## Template Files

### Naming Convention

- Add `.tmpl` suffix to any file that needs processing
- Examples:
  - `dot_bashrc.tmpl`
  - `dot_gitconfig.tmpl`
  - `run_once_install.sh.tmpl`

### Processing Order

1. Chezmoi reads the template file
2. Processes template directives
3. Writes the result to the target location
4. Sets appropriate permissions

## Best Practices

### 1. Use Clear Variable Names

```toml
# Good
[data]
personalEmail = "me@example.com"
workEmail = "me@company.com"

# Avoid
[data]
email1 = "me@example.com"
email2 = "me@company.com"
```

### 2. Provide Defaults

```bash
# Use default values for optional data
export EDITOR="{{ .editor | default "vim" }}"
export BROWSER="{{ .browser | default "firefox" }}"
```

### 3. Comment Complex Logic

```bash
{{- /* 
    Configure package manager based on distribution
    Ubuntu/Debian: apt
    AlmaLinux/RHEL: yum/dnf
*/ -}}
{{- if .isUbuntu }}
export PKG_MANAGER="apt"
{{- else if .isAlmaLinux }}
export PKG_MANAGER="yum"
{{- end }}
```

### 4. Test Templates

Preview template output:
```bash
chezmoi execute-template < template.tmpl
```

Debug with data:
```bash
echo '{{ .emailFree }}' | chezmoi execute-template
```

## Advanced Usage

### Template Data from Commands

```bash
# Get data from external commands
{{- $gitVersion := output "git" "--version" | trim }}
export GIT_VERSION="{{ $gitVersion }}"
```

### Include Other Templates

```bash
# Include shared configuration
{{ template "shared/header.tmpl" . }}

# Main configuration here

{{ template "shared/footer.tmpl" . }}
```

### Loops and Ranges

```bash
# Generate multiple aliases
{{- range $alias, $command := .aliases }}
alias {{ $alias }}="{{ $command }}"
{{- end }}
```

## Debugging

### View Template Data

```bash
# Show all available data
chezmoi data

# Show specific data
chezmoi data | jq '.isUbuntu'
```

### Test Template Execution

```bash
# Test a specific template
chezmoi execute-template ~/.local/share/chezmoi/dot_bashrc.tmpl

# Test with custom data
echo '{{ .testVar }}' | chezmoi execute-template --init --promptString testVar="value"
```

### Common Issues

1. **Syntax Errors**: Check for unclosed `{{` blocks
2. **Missing Data**: Ensure variables are defined in config
3. **Whitespace**: Use `{{-` and `-}}` to control whitespace
4. **Escaping**: Use raw strings for literal braces: `{{ "{{" }}`