# yadm/gpg.bash
# This file is part of yadm.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_YADM_GPG" ] && return 0
_YADM_GPG=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::bitwarden::init

# yadm::bitwarden::restore
# download attachments from secrets.github.com
# load them into gpg
# delete ascii-armored files

# yadm::bitwarden::backup
# export keypair for yadm@secrets.github.com
# upload attachments to secrets.github.com
# delete ascii-armored files
