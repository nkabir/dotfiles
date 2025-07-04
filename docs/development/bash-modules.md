# Bash Modules

The bash configuration system uses a modular approach, allowing you to enable only the features you need.

## Module Structure

Modules are organized in two directories:

- `~/.bashrc.avail/` - Available modules (all possible modules)
- `~/.bashrc.d/` - Enabled modules (symlinks to available modules)

## Module Naming Convention

Modules follow a numbered naming pattern:

```
XXX-module-name.bash
```

Where `XXX` is a three-digit number that controls loading order:

- `000-099`: Core system setup
- `100-199`: Shell configuration
- `200-299`: Development tools
- `300-399`: Language-specific settings
- `400-499`: Application integrations
- `500-599`: User customizations
- `600-699`: Company/organization specific
- `700-799`: Project specific
- `800-899`: Experimental features
- `900-999`: Final setup and cleanup

## Available Modules

### Core Modules (000-099)
- `001-logger.bash` - Logging system initialization
- `010-env.bash` - Environment variable setup

### Shell Configuration (100-199)
- `100-bash-settings.bash` - Basic bash configuration
- `110-bash-aliases.bash` - Common aliases
- `120-bash-functions.bash` - Utility functions
- `150-starship.bash` - Starship prompt

### Development Tools (200-299)
- `200-git.bash` - Git configuration and aliases
- `210-ssh.bash` - SSH agent and key management
- `220-direnv.bash` - Directory-based environments
- `250-homebrew.bash` - Homebrew package manager

### Language Support (300-399)
- `300-golang.bash` - Go language environment
- `310-python.bash` - Python and pip configuration
- `320-rust.bash` - Rust and cargo setup
- `330-node.bash` - Node.js and npm/yarn

### Application Integration (400-499)
- `400-emacs.bash` - Emacs editor support
- `410-tilix.bash` - Tilix terminal integration

## Managing Modules

### Enabling a Module

Modules are automatically linked during ChezMoi apply:

```bash
chezmoi apply
```

The `run_after_900-link-bash.sh.tmpl` script creates symlinks based on your configuration.

### Disabling a Module

Remove the symlink from `~/.bashrc.d/`:

```bash
rm ~/.bashrc.d/300-golang.bash
```

### Creating a Custom Module

1. Create a new file in the ChezMoi source:
   ```bash
   chezmoi edit ~/.bashrc.avail/550-custom.bash
   ```

2. Add your configuration:
   ```bash
   #!/usr/bin/env bash
   # Custom module for personal settings
   
   # Your configuration here
   export MY_CUSTOM_VAR="value"
   
   # Custom functions
   my_function() {
       echo "Hello from custom module"
   }
   ```

3. Apply changes:
   ```bash
   chezmoi apply
   ```

## Module Templates

Modules can use ChezMoi templates for conditional logic:

```bash
{{- if .isUbuntu }}
# Ubuntu-specific configuration
alias update='sudo apt update && sudo apt upgrade'
{{- else if .isAlmaLinux }}
# AlmaLinux-specific configuration
alias update='sudo dnf update'
{{- end }}
```

## Module Dependencies

Some modules depend on others. Dependencies are managed through:

1. **Naming order**: Lower numbers load first
2. **Conditional checks**: Modules can check for required commands
3. **Library usage**: Modules can source shared libraries

Example dependency check:

```bash
# Check if git is available
if command -v git &> /dev/null; then
    # Git-specific configuration
    alias gs='git status'
fi
```

## Best Practices

1. **Keep modules focused**: One feature per module
2. **Use proper ordering**: Dependencies load first
3. **Document your modules**: Add comments explaining configuration
4. **Test before applying**: Use `chezmoi diff` to preview changes
5. **Use templates**: Make modules work across different systems

## Troubleshooting

If modules aren't loading:

1. Check symlinks exist:
   ```bash
   ls -la ~/.bashrc.d/
   ```

2. Verify module is executable:
   ```bash
   ls -la ~/.bashrc.avail/
   ```

3. Re-run the linking script:
   ```bash
   chezmoi state delete-bucket --bucket=scriptState
   chezmoi apply
   ```

4. Check for syntax errors:
   ```bash
   bash -n ~/.bashrc.d/module-name.bash
   ```