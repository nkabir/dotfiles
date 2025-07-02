# About This Project

This repository contains personal dotfiles managed by `chezmoi`. It is designed to automate the setup and configuration of a consistent development environment across multiple machines. The configuration is heavily templated and modular.

# Key Technologies & Conventions

- **`chezmoi`**: The core tool for managing configuration files. It symlinks or generates files in the home directory based on the contents of this repository (the "source state").
- **`Shell (Bash)`**: The primary language for setup scripts (`run_*`), helpers, and shell configuration (`.bashrc`).
- **`Go Templating`**: Most configuration files are `.tmpl` files that use `chezmoi`'s Go-based templating engine. Data for templates is stored in `.chezmoidata/`.
- **`Secrets Management`**: The `blackbox/` directory indicates that secrets are managed using `chezmoi`'s capabilities, likely encrypted in the git repository and decrypted on `chezmoi apply`.
- **`Modular `.bashrc``**: The `.bashrc` is constructed modularly from files in `dot_bashrc.avail/`. A script (`run_after_900-link-bash.sh.tmpl`) likely links the enabled modules into place.
- **`Realms`**: The `realms/` directory suggests different configurations for different contexts (e.g., work vs. personal, different git providers).

# Project Structure

- **`blackbox/`**: The main `chezmoi` source directory. Most managed files reside here. The name suggests it's the directory that might be encrypted.
- **`dot_scripts/`**: Contains scripts executed by `chezmoi` during `apply`. Prefixes like `run_once_`, `run_before_`, and `run_after_` control when they run.
- **`.chezmoidata/`**: Contains `.toml` files with data (variables) that are injected into the `.tmpl` templates. This is how the configuration is customized.
- **`.chezmoitemplates/`**: Holds reusable Go template snippets that can be included in other templates.
- **`realms/`**: Defines environment-specific configurations that can be layered on top of the base configuration.

# Common Tasks

### Applying Changes
To apply the dotfiles to the local system, run:
```bash
chezmoi apply
```

### Adding a New Configuration File
1.  Create the file within the `blackbox/` directory using the appropriate `chezmoi` target name. For example, to create `~/.newconfig`, add a file named `blackbox/dot_newconfig`.
2.  If the file needs to be a template, add the `.tmpl` extension (e.g., `blackbox/dot_newconfig.tmpl`) and use Go template syntax within it.

### Modifying Template Data
To change the variables used in templates (e.g., user name, email, package lists), edit the `.toml` files in the `.chezmoidata/` directory.

### Adding a New Setup Script
1.  Add a new executable script to `dot_scripts/setup/`.
2.  Use a `run_once_` prefix to have it run only on the first `chezmoi apply`.
3.  Use a number to control the execution order (e.g., `run_once_800-install-new-tool.sh`).
