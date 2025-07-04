# Configuration

This guide covers how to configure CWIQ Seed dotfiles for your environment.

## Chezmoi Configuration

### Initial Setup

Run the configuration wizard:

```bash
chezmoi edit-config
```

This opens your configuration file in your default editor.

### Configuration Options

The main configuration file (`~/.config/chezmoi/chezmoi.toml`) supports:

```toml
[data]
# Personal Information
emailFree = "personal@example.com"
emailCorp = "work@company.com"
githubId = "yourusername"
homeRealm = "com.example.yourdomain"

# System Detection (automatically set)
isUbuntu = true
isAlmaLinux = false
```

## Environment Variables

### Shell Environment

Key environment variables are configured in `~/.bashrc.d/`:

- `000-environment.bash` - Core environment setup
- `100-path.bash` - PATH configuration
- `200-aliases.bash` - Command aliases

### Development Environments

For project-specific configurations, use direnv:

```bash
# In your project directory
echo 'export PROJECT_VAR="value"' > .envrc
direnv allow
```

## Package Management

### Homebrew

Configure Homebrew packages in `~/.config/homebrew/Brewfile`:

```ruby
# Development tools
brew "git"
brew "node"
brew "python"

# Utilities
brew "ripgrep"
brew "fd"
brew "bat"
```

Apply with:

```bash
brew bundle --file=~/.config/homebrew/Brewfile
```

### Local Debian Repository

Configure your local package repository:

```bash
# Initialize repository
~/.local/bin/deb-repo-init.sh

# Add packages
~/.local/bin/deb-repo-add.sh package.deb
```

## Bash Modules

### Available Modules

List available modules:

```bash
ls ~/.bashrc.avail/
```

### Enable/Disable Modules

Modules are enabled by symlinking to `~/.bashrc.d/`:

```bash
# Enable a module
ln -s ~/.bashrc.avail/300-docker.bash ~/.bashrc.d/

# Disable a module
rm ~/.bashrc.d/300-docker.bash
```

## Secret Management

### Bitwarden Integration

Configure Bitwarden for secret management:

```bash
# Login to Bitwarden
bw login

# Store session
export BW_SESSION="your-session-key"
```

Use in scripts:

```bash
. ~/.local/lib/bitwarden/core.bash
bitwarden:init
SECRET=$(bitwarden:get "item-name" "field-name")
```

## Git Configuration

### Global Git Config

Managed by chezmoi templates:

```gitconfig
[user]
    name = Your Name
    email = {{ .emailFree }}

[github]
    user = {{ .githubId }}

[includeIf "gitdir:~/realms/{{ .homeRealm }}/"]
    path = ~/.gitconfig.personal

[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

### Work vs Personal

Create separate configs:

`~/.gitconfig.personal`:
```gitconfig
[user]
    email = {{ .emailFree }}
```

`~/.gitconfig.work`:
```gitconfig
[user]
    email = {{ .emailCorp }}
```

## IDE Integration

### VS Code

Settings are managed in `~/.config/Code/User/settings.json`:

```json
{
    "editor.fontFamily": "'Anonymous Pro', monospace",
    "terminal.integrated.fontFamily": "'Anonymous Pro'",
    "workbench.colorTheme": "One Dark Pro"
}
```

### Vim

Configure via `~/.vimrc`:

```vim
" Managed by chezmoi
source ~/.vim/config/base.vim
source ~/.vim/config/plugins.vim
```

## Troubleshooting

### Debug Mode

Enable chezmoi debug output:

```bash
chezmoi apply --debug
```

### Check Templates

Preview template output:

```bash
chezmoi execute-template < ~/.local/share/chezmoi/dot_bashrc.tmpl
```

### Reset Configuration

Start fresh:

```bash
chezmoi purge
chezmoi init https://github.com/yourusername/dotfiles.git
```