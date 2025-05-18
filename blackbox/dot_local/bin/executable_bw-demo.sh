#!/usr/bin/env bash
# bin/bw-demo.sh
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${HERE:?}/../lib/logger/core.bash"
. "${HERE:?}/../lib/bitwarden/core.bash"
. "${HERE:?}/../lib/gum/core.bash"

bitwarden::logout
