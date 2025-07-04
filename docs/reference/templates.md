# Templates Reference

Complete reference for chezmoi template syntax, functions, and variables used in CWIQ Seed.

## Template Basics

### File Naming

Templates are identified by the `.tmpl` suffix:

```
dot_bashrc.tmpl          → ~/.bashrc
dot_gitconfig.tmpl       → ~/.gitconfig
run_once_install.sh.tmpl → (executed during chezmoi apply)
```

### Syntax Overview

```go
{{/* This is a comment */}}

{{ .variable }}                    {{/* Variable substitution */}}
{{ .variable | upper }}            {{/* With function */}}
{{ if .condition }} ... {{ end }}  {{/* Conditional */}}
{{ range .items }} ... {{ end }}   {{/* Loop */}}
```

## Available Variables

### User-Defined Variables

From `~/.config/chezmoi/chezmoi.toml`:

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `.emailFree` | string | Personal email | `"me@example.com"` |
| `.emailCorp` | string | Work email | `"me@company.com"` |
| `.githubId` | string | GitHub username | `"myusername"` |
| `.homeRealm` | string | Primary realm domain | `"com.github"` |
| `.fullName` | string | User's full name | `"John Doe"` |

### System Variables

Automatically detected by chezmoi:

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `.chezmoi.arch` | string | System architecture | `"amd64"`, `"arm64"` |
| `.chezmoi.hostname` | string | Machine hostname | `"laptop"` |
| `.chezmoi.os` | string | Operating system | `"linux"`, `"darwin"` |
| `.chezmoi.username` | string | Current username | `"john"` |
| `.chezmoi.fqdn` | string | Fully qualified domain | `"laptop.local"` |
| `.chezmoi.homeDir` | string | User home directory | `"/home/john"` |
| `.chezmoi.sourceDir` | string | Chezmoi source directory | `"/home/john/.local/share/chezmoi"` |

### CWIQ Seed Variables

Custom boolean flags:

| Variable | Type | Description |
|----------|------|-------------|
| `.isUbuntu` | bool | Running on Ubuntu |
| `.isAlmaLinux` | bool | Running on AlmaLinux |
| `.isDesktop` | bool | Desktop environment detected |
| `.isServer` | bool | Server environment |
| `.isDocker` | bool | Running inside Docker |
| `.isWSL` | bool | Running in WSL |

## Template Functions

### String Functions

```go
{{ "hello" | upper }}              → "HELLO"
{{ "HELLO" | lower }}              → "hello"
{{ "hello world" | title }}        → "Hello World"
{{ "  trim me  " | trim }}         → "trim me"
{{ "hello" | repeat 3 }}           → "hellohellohello"
{{ "hello" | replace "l" "r" }}    → "herro"
{{ "hello world" | contains "wor" }} → true
{{ "prefix_value" | trimPrefix "prefix_" }} → "value"
{{ "value_suffix" | trimSuffix "_suffix" }} → "value"
```

### Type Conversion

```go
{{ "123" | int }}                  → 123
{{ "true" | bool }}                → true
{{ 123 | toString }}               → "123"
{{ "1.5" | float64 }}              → 1.5
```

### List Operations

```go
{{ list "a" "b" "c" }}             → ["a", "b", "c"]
{{ list 1 2 3 | join "," }}        → "1,2,3"
{{ "a,b,c" | split "," }}          → ["a", "b", "c"]
{{ list 1 2 3 | first }}           → 1
{{ list 1 2 3 | last }}            → 3
{{ list 1 2 3 | reverse }}         → [3, 2, 1]
{{ list 1 2 1 | uniq }}            → [1, 2]
```

### Path Functions

```go
{{ "/path/to/file.txt" | base }}   → "file.txt"
{{ "/path/to/file.txt" | dir }}    → "/path/to"
{{ "/path/to/file.txt" | ext }}    → ".txt"
{{ "~/file" | expandenv }}         → "/home/user/file"
{{ joinPath .chezmoi.homeDir ".config" "app" }} → "/home/user/.config/app"
```

### Logic Functions

```go
{{ if eq .os "linux" }}            {{/* Equal */}}
{{ if ne .os "darwin" }}           {{/* Not equal */}}
{{ if lt .version 10 }}            {{/* Less than */}}
{{ if le .version 10 }}            {{/* Less or equal */}}
{{ if gt .version 5 }}             {{/* Greater than */}}
{{ if ge .version 5 }}             {{/* Greater or equal */}}
{{ if and .isUbuntu .isDesktop }}  {{/* Logical AND */}}
{{ if or .isUbuntu .isDebian }}    {{/* Logical OR */}}
{{ if not .isServer }}             {{/* Logical NOT */}}
```

### Default Values

```go
{{ .editor | default "vim" }}      {{/* Use vim if .editor not set */}}
{{ .port | default 8080 }}         {{/* Use 8080 if .port not set */}}
{{ default "red" .color }}         {{/* Alternative syntax */}}
```

## Control Structures

### Conditionals

**Simple if:**
```go
{{ if .isUbuntu }}
export DISTRO="ubuntu"
{{ end }}
```

**If-else:**
```go
{{ if .isUbuntu }}
export PKG_MANAGER="apt"
{{ else }}
export PKG_MANAGER="yum"
{{ end }}
```

**If-else if-else:**
```go
{{ if .isUbuntu }}
export DISTRO="ubuntu"
{{ else if .isAlmaLinux }}
export DISTRO="almalinux"
{{ else }}
export DISTRO="unknown"
{{ end }}
```

**Nested conditions:**
```go
{{ if .isLinux }}
  {{ if .isDesktop }}
    # Linux desktop specific
  {{ else }}
    # Linux server specific
  {{ end }}
{{ end }}
```

### Loops

**Range over list:**
```go
{{ range list "vim" "git" "curl" }}
- {{ . }}
{{ end }}
```

**Range with index:**
```go
{{ range $index, $value := list "a" "b" "c" }}
{{ $index }}: {{ $value }}
{{ end }}
```

**Range over map:**
```go
{{ range $key, $value := .aliases }}
alias {{ $key }}="{{ $value }}"
{{ end }}
```

### Variables

**Define variables:**
```go
{{ $myVar := "hello" }}
{{ $myVar }}

{{ $packages := list "git" "vim" "curl" }}
{{ range $packages }}
- {{ . }}
{{ end }}
```

**With statement:**
```go
{{ with .githubToken }}
export GITHUB_TOKEN="{{ . }}"
{{ else }}
# No GitHub token configured
{{ end }}
```

## Whitespace Control

### Trim whitespace

```go
{{- "text" }}     {{/* Trim left whitespace */}}
{{ "text" -}}     {{/* Trim right whitespace */}}
{{- "text" -}}    {{/* Trim both sides */}}
```

**Example:**
```bash
export VAR="
{{- if .condition -}}
value
{{- else -}}
other
{{- end -}}
"
# Result: export VAR="value" (no extra newlines)
```

## Advanced Patterns

### OS-Specific Package Lists

```go
{{- $packages := list -}}
{{- if .isUbuntu -}}
  {{- $packages = list "build-essential" "ubuntu-restricted-extras" -}}
{{- else if .isAlmaLinux -}}
  {{- $packages = list "gcc" "make" "development-tools" -}}
{{- end -}}

# Install packages
{{ range $packages -}}
install_package {{ . }}
{{ end }}
```

### Dynamic Git Configuration

```go
[user]
    name = {{ .fullName | quote }}
    email = {{ if contains "work" .chezmoi.hostname }}{{ .emailCorp | quote }}{{ else }}{{ .emailFree | quote }}{{ end }}

{{- if .githubToken }}
[github]
    token = {{ .githubToken | quote }}
{{- end }}

[includeIf "gitdir:~/realms/{{ .homeRealm }}/"]
    path = ~/.gitconfig.personal
```

### Conditional File Installation

In `.chezmoiignore`:
```go
{{- if not .isDesktop }}
.config/fontconfig/
.config/gtk-3.0/
.local/share/applications/
{{- end }}

{{- if not .isServer }}
.config/nginx/
.config/systemd/
{{- end }}

{{- if ne .chezmoi.os "linux" }}
.config/linux-only/
{{- end }}
```

### Shell Script Generation

```go
#!/bin/bash
# Generated for {{ .chezmoi.hostname }} on {{ .chezmoi.os }}/{{ .chezmoi.arch }}

{{- if .isUbuntu }}
# Ubuntu-specific setup
source /etc/lsb-release
DISTRO_VERSION=$DISTRIB_RELEASE
{{- else if .isAlmaLinux }}
# AlmaLinux-specific setup
source /etc/os-release
DISTRO_VERSION=$VERSION_ID
{{- end }}

# Common setup
export PATH="{{ .chezmoi.homeDir }}/.local/bin:$PATH"

{{- range $key, $value := .envVars }}
export {{ $key }}="{{ $value }}"
{{- end }}
```

### Complex Data Structures

```toml
# In chezmoi.toml
[data.servers]
  [data.servers.web]
    host = "web.example.com"
    port = 443
  [data.servers.db]
    host = "db.example.com"
    port = 5432
```

```go
# In template
{{ range $name, $server := .servers }}
# {{ $name }} server
Host {{ $name }}
    HostName {{ $server.host }}
    Port {{ $server.port }}
{{ end }}
```

## External Data Sources

### Command Output

```go
{{- $gitVersion := output "git" "--version" | trim -}}
# Git version: {{ $gitVersion }}

{{- $kernelVersion := output "uname" "-r" | trim -}}
# Kernel: {{ $kernelVersion }}
```

### Include Files

```go
# Include another template
{{ template "common/header.tmpl" . }}

# Include raw file content
{{ include "files/config.txt" }}
```

### JSON/YAML Data

```go
{{- $config := include "config.json" | fromJson -}}
Server: {{ $config.server }}
Port: {{ $config.port }}
```

## Error Handling

### Required Values

```go
# Will error if variable not set
{{ .requiredVar | required "requiredVar must be set" }}

# With default fallback
{{ .optionalVar | default "defaultValue" }}
```

### Safe Access

```go
# Check if key exists
{{ if hasKey . "optional" }}
Value: {{ .optional }}
{{ end }}

# Check nested values
{{ if and .config .config.server .config.server.host }}
Host: {{ .config.server.host }}
{{ end }}
```

## Testing Templates

### Preview Output

```bash
# Test a template file
chezmoi execute-template < ~/.local/share/chezmoi/dot_gitconfig.tmpl

# Test inline template
echo '{{ .chezmoi.hostname }}' | chezmoi execute-template
```

### Debug Data

```bash
# Show all available data
chezmoi data

# Show specific value
chezmoi data | jq '.isUbuntu'

# Test with custom data
chezmoi execute-template --init \
  --promptBool isUbuntu=true \
  --promptString emailFree="test@example.com" \
  < template.tmpl
```

## Common Gotchas

### 1. Quote Special Characters

```go
# Bad
password = {{ .password }}

# Good
password = {{ .password | quote }}
```

### 2. Handle Missing Data

```go
# Bad
{{ .optional }}

# Good
{{ .optional | default "" }}
```

### 3. Escape Template Syntax

```go
# To output literal {{
{{ "{{" }} .variable {{ "}}" }}

# Alternative
` + "`" + `{{ .variable }}` + "`" + `
```

### 4. Line Endings

```go
# Preserve exact formatting
{{ range $line := splitList "\n" .content -}}
{{ $line }}
{{ end -}}
```