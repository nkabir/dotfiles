# ChezMoi template for managing .bashrc.d snippets
# This creates a hierarchical bash configuration structure

# Create the main structure in .chezmoifiles
# File: ~/.local/share/chezmoi/.chezmoifiles
{{- /* .chezmoiscripts/.bashrc_setup.sh */ -}}
{{- /* .chezmoitemplates/bashrc.d/010-homebrew.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/020-aliases.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/030-functions.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/050-git.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/060-history.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/070-prompt.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/080-path.bash.tmpl */ -}}
{{- /* .chezmoitemplates/bashrc.d/090-completion.bash.tmpl */ -}}
{{- if eq .chezmoi.os "darwin" -}}
{{- /* .chezmoitemplates/bashrc.d/100-macos.bash.tmpl */ -}}
{{- end -}}
{{- if eq .chezmoi.os "linux" -}}
{{- /* .chezmoitemplates/bashrc.d/100-linux.bash.tmpl */ -}}
{{- end -}}

# File: ~/.local/share/chezmoi/.chezmoiscripts/.bashrc_setup.sh (executable)
#!/bin/bash

# Create .bashrc.d directory if it doesn't exist
mkdir -p "${HOME}/.bashrc.d"

# Add loader to .bashrc if it doesn't exist
if ! grep -q "source ~/.bashrc.d/loader.sh" "${HOME}/.bashrc"; then
  echo -e "\n# Load modular bash configuration\nif [ -f ~/.bashrc.d/loader.sh ]; then\n  source ~/.bashrc.d/loader.sh\nfi" >> "${HOME}/.bashrc"
  echo "Added .bashrc.d loader to .bashrc"
fi

# Create loader.sh in ~/.bashrc.d
cat > "${HOME}/.bashrc.d/loader.sh" << 'EOF'
#!/bin/bash
# This script loads all bash configuration files in .bashrc.d

# Load all .bash files in .bashrc.d directory in numerical order
if [ -d "${HOME}/.bashrc.d" ]; then
  for file in $(ls -1 ${HOME}/.bashrc.d/*.bash 2>/dev/null | sort); do
    source "$file"
  done
fi
EOF

chmod +x "${HOME}/.bashrc.d/loader.sh"
echo ".bashrc.d setup complete"

# File: ~/.local/share/chezmoi/.chezmoitemplates/bashrc.d/010-homebrew.bash.tmpl
#!/bin/bash
# Homebrew configuration

{{- if eq .chezmoi.os "darwin" }}
# macOS Homebrew setup
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
fi
{{- end }}

{{- if eq .chezmoi.os "linux" }}
# Linux Homebrew setup
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
elif [ -f "${HOME}/.linuxbrew/bin/brew" ]; then
  eval "$(${HOME}/.linuxbrew/bin/brew shellenv)"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
fi
{{- end }}

# File: ~/.local/share/chezmoi/.chezmoitemplates/bashrc.d/020-aliases.bash.tmpl
#!/bin/bash
# Common aliases

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -la'
{{- if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
{{- else }}
alias ls='ls --color=auto'
{{- end }}

# Git shortcuts
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

{{- if .customAliases }}
# Custom aliases
{{ range .customAliases }}
alias {{ .name }}='{{ .command }}'
{{- end }}
{{- end }}

# File: ~/.local/share/chezmoi/.chezmoitemplates/bashrc.d/040-development.bash.tmpl
#!/bin/bash
# Development environment configuration

# Add local binary directory to PATH
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# File: ~/.local/share/chezmoi/.chezmoitemplates/bashrc.d/100-macos.bash.tmpl
#!/bin/bash
# macOS specific configuration

# Set PATH to include macOS specific tools
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# macOS specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias cleanup='find . -type f -name "*.DS_Store" -delete'

# File: ~/.local/share/chezmoi/.chezmoitemplates/bashrc.d/100-linux.bash.tmpl
#!/bin/bash
# Linux specific configuration

# Set PATH to include user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# Linux specific aliases
alias open='xdg-open'
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# Create a template for .chezmoi.toml config file
# File: ~/.local/share/chezmoi/.chezmoi.toml.tmpl
# Chezmoi configuration

# User information
[data]
name = "{{ .chezmoi.username }}"
email = "{{ promptString "email" }}"

# Custom aliases (uncomment and modify to add custom aliases)
# [[data.customAliases]]
# name = "myalias"
# command = "echo 'This is my custom alias'"
# 
# [[data.customAliases]]
# name = "projects"
# command = "cd ~/Projects"

# Initialize the .bashrc.d directory with run_once script
# File: ~/.local/share/chezmoi/run_once_setup_bashrc_d.sh.tmpl
#!/bin/bash

echo "Setting up modular .bashrc.d configuration..."
mkdir -p "${HOME}/.bashrc.d"

# Create loader script if it doesn't exist
if [ ! -f "${HOME}/.bashrc.d/loader.sh" ]; then
  cat > "${HOME}/.bashrc.d/loader.sh" << 'EOF'
#!/bin/bash
# This script loads all bash configuration files in .bashrc.d

# Load all .bash files in .bashrc.d directory in numerical order
if [ -d "${HOME}/.bashrc.d" ]; then
  for file in $(ls -1 ${HOME}/.bashrc.d/*.bash 2>/dev/null | sort); do
    source "$file"
  done
fi
EOF
  chmod +x "${HOME}/.bashrc.d/loader.sh"
fi

# Add source line to .bashrc if it doesn't exist
if ! grep -q "source ~/.bashrc.d/loader.sh" "${HOME}/.bashrc"; then
  echo -e "\n# Load modular bash configuration\nif [ -f ~/.bashrc.d/loader.sh ]; then\n  source ~/.bashrc.d/loader.sh\nfi" >> "${HOME}/.bashrc"
  echo "Added .bashrc.d loader to .bashrc"
fi

echo "Bash modular configuration setup complete!"
