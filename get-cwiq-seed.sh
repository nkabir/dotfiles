#!/usr/bin/env bash
set -euo pipefail

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# CWIQ Seed Go
#
# This script is part of the CWIQ Seed project.
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# This script is intended to be run on a fresh machine to set up a
# development environment. It install the necessary packages and
# configure the system to be ready for development. The user must have
# sudo privileges.
#
# urls:
# - https://tinyurl.com/get-cwiq-seed redirects to
# - https://raw.githubusercontent.com/cwiq-seed/dotfiles/refs/heads/develop/get-cwiq-seed.sh
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
#
# 1. Fork the dotfiles repository to your Github account
#    https://github.com/cwiq-seed/dotfiles
# 2. Execute this script with
#    export GITHUB_ID="your-github-id"
#    curl -L https://tinyurl.com/get-cwiq-seed | bash
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ -f "/etc/redhat-release" ]]; then
  # default git install for Fedora
  sudo dnf install -y git
fi

# Validate GITHUB_ID format
if [[ ! "${GITHUB_ID:-}" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
    echo "Error: GITHUB_ID must be a valid GitHub username"
    exit 1
fi

# Verify network connectivity
if ! curl -sf --connect-timeout 5 https://github.com >/dev/null; then
    echo "Error: Cannot reach GitHub"
    exit 1
fi

# Verify repository exists
if ! curl -sf "https://api.github.com/repos/${GITHUB_ID}/dotfiles" >/dev/null; then
    echo "Error: Repository ${GITHUB_ID}/dotfiles not found"
    exit 1
fi

# Download ChezMoi installer with checksum verification
CHEZMOI_INSTALLER=$(mktemp)
trap "rm -f ${CHEZMOI_INSTALLER}" EXIT

curl -fsSL https://get.chezmoi.io -o "${CHEZMOI_INSTALLER}"
# Add checksum verification here
chmod +x "${CHEZMOI_INSTALLER}"
"${CHEZMOI_INSTALLER}" -- init --apply "${GITHUB_ID}"
