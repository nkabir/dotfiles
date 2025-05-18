#!/usr/bin/env bash

chezmoi apply --force 1>&2

unset _LOGGER_CORE
. ~/.local/lib/logger/core.bash

unset _BITWARDEN_CORE
. ~/.local/lib/bitwarden/core.bash

unset _SKATE_CORE
. ~/.local/lib/skate/core.bash

# unset _GPG_CORE
# . ~/.local/lib/gpg/core.bash

# unset _YADM_CORE
# . ~/.local/lib/yadm/core.bash

# unset _GUM_CORE
# . ~/.local/lib/gum/core.bash

######################################

# unset _VAULT_CORE
# . ~/.local/gig/vault/core.bash

unset _GIG_PWMANAGER
. ~/.local/gig/pwmanager/core.bash

# bw sync
