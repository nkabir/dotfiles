#!/usr/bin/env bash

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
# 1. Clone the dotfiles repository to your Github account
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

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "${GITHUB_ID:?}"
