# Quick Start

This guide will help you get up and running with CWIQ Seed dotfiles in minutes.

## Prerequisites

Before you begin, ensure you have:

- A supported operating system (Ubuntu 20.04+ or AlmaLinux 8+)
- Git installed
- curl or wget for downloading installers

## Installation

### One-line Installation

For a quick setup, run:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh)"
```

Or if you prefer wget:

```bash
sh -c "$(wget -qO- https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh)"
```

### Manual Installation

1. **Install Chezmoi**:
   ```bash
   sh -c "$(curl -fsLS https://chezmoi.io/get)"
   ```

2. **Initialize with your dotfiles**:
   ```bash
   chezmoi init https://github.com/yourusername/dotfiles.git
   ```

3. **Apply the configuration**:
   ```bash
   chezmoi apply
   ```

## First Steps

### Check Status

See what changes will be applied:

```bash
chezmoi diff
```

### Apply Changes

Apply all configurations:

```bash
chezmoi apply
```

### Enable Bash Modules

The system includes modular bash configurations. To enable available modules:

```bash
~/.scripts/after/run_after_900-link-bash.sh
```

### Configure Git

Set up your Git identity:

```bash
chezmoi edit-config
```

Add your details:

```toml
[data]
emailFree = "your-personal@email.com"
emailCorp = "your-work@email.com"
githubId = "yourusername"
```

## Common Tasks

### Add a New Dotfile

To manage an existing configuration file with chezmoi:

```bash
chezmoi add ~/.config/myapp/config
```

### Edit and Apply

Edit a managed file and apply changes:

```bash
chezmoi edit ~/.bashrc
chezmoi apply
```

### Update from Repository

Pull latest changes and apply:

```bash
chezmoi update
```

## Next Steps

- [Configuration Guide](configuration.md) - Customize your setup
- [Architecture Overview](../architecture/overview.md) - Understand the system structure
- [Bash Modules](../development/bash-modules.md) - Learn about available modules