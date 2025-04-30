#!/usr/bin/env bash
# demo.sh to set up bw gpg
# This script is used to set up the Bitwarden CLI with GPG encryption.

THIS_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. ${THIS_HERE}/bw-common.bash

ensure_bw_folder "seed"
ensure_bw_note "seed.gpg" "seed" "Managed by bw-gpg scripts. Do not edit."
asc=$(bw_download_attachment "seed.gpg" "yadm-bw-key.asc" "./yadm-bw-key.asc")

if [ -z "$asc" ]; then
    echo "No seed.asc file found. Please create it first."
    bw_gpg_upload "seed" "seed.gpg"
fi
