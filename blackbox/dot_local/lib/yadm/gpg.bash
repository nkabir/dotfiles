# yadm/gpg.bash
# This file is part of yadm.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_YADM_GPG" ] && return 0
_YADM_GPG=1


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::init
# create a new keypair in gpg with email yadm@secrets.github.com if it does not exist


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::backup
# export the keypair to files


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# yadm::gpg::restore
# import the keypair from files
