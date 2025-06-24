#!/usr/bin/env bash

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# CWIQ Seed Go
#
# This script is part of the CWIQ Seed project.
# When changed, it must be placed in the "downloads" section
# of the Bitbucket repository.
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# This script is intended to be run on a fresh machine to set up a
# development environment. It install the necessary packages and
# configure the system to be ready for development. The user must have
# sudo privileges.
#
# urls:
# - https://tinyurl.com/cwiq-seed-go redirects to
# - https://bitbucket.org/cwiq/seed/downloads/cwiq-seed-go.sh
#
# We use Bitbucket to host the script because Github does not allow
# raw file downloads from repositories. This is a workaround to allow
# us to host the script and still allow users to download it.
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Usage:
# 1. Clone the dotfiles repository to your Github account
#    https://github.com/cwiq-seed/dotfiles
# 2. Execute this script with
#    export GITHUB_USER="your-username"
#    curl -L https://tinyurl.com/cwiq-seed-go | bash
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
if [[ -f "/etc/redhat-release" ]]; then
  # default git install for Fedora
  sudo dnf install -y git
fi

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "${GITHUB_USER:?}"
