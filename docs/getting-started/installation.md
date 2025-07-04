# Installation

This guide will walk you through installing the ChezMoi dotfiles on your system.

## Prerequisites

Before installing, ensure you have:

- Ubuntu 20.04+ or AlmaLinux 8+
- Git installed
- Curl installed
- Sudo access

## Quick Install

The fastest way to get started is using the automated installer:

```bash
export GITHUB_ID="your-github-id"
curl -L https://tinyurl.com/get-cwiq-seed | bash
```

This will:
1. Install ChezMoi if not already present
2. Clone the dotfiles repository
3. Apply the initial configuration

## Manual Installation

If you prefer more control over the installation process:

### 1. Install ChezMoi

=== "Ubuntu"

    ```bash
    sudo sh -c "$(curl -fsLS chezmoi.io/get)" -- -b /usr/local/bin
    ```

=== "AlmaLinux"

    ```bash
    sudo sh -c "$(curl -fsLS chezmoi.io/get)" -- -b /usr/local/bin
    ```

### 2. Initialize ChezMoi

```bash
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```

### 3. Configure Your Environment

Edit your ChezMoi configuration:

```bash
chezmoi edit-config
```

Add your personal information:

```toml
[data]
emailFree = "your-personal@email.com"
emailCorp = "your-work@email.com"
githubId = "your-github-username"
operator = "Your Full Name"
homeRealm = "com.github/yourusername"
```

### 4. Apply Configuration

```bash
chezmoi apply
```

## Post-Installation

After installation, you may want to:

1. Enable additional bash modules (see [Bash Modules](../development/bash-modules.md))
2. Configure your local package repositories (see [Package Management](../development/package-management.md))
3. Set up your development realms (see [Realms Structure](../development/realms.md))

## Verification

To verify the installation was successful:

```bash
# Check ChezMoi version
chezmoi --version

# View managed files
chezmoi managed

# Check for any differences
chezmoi diff
```

## Troubleshooting

If you encounter issues during installation:

1. Ensure all prerequisites are met
2. Check system logs: `journalctl -xe`
3. Run ChezMoi in verbose mode: `chezmoi apply -v`
4. See the [troubleshooting guide](troubleshooting.md) for common issues