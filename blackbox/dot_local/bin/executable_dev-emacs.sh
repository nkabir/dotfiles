#!/usr/bin/env bash

# Override when needed
export POLYLITH_EMACS=$HOME/realms/rkx/src/polylith/emacs

HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

emacs --debug-init --init-directory "$POLYLITH_EMACS/development" --no-splash $@


