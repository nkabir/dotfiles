# yadm/gpg.bash
# This file is part of yadm.
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# returns the gpg recipient
yadm::gpg::uid() {

    yadm config yadm.gpg-recipient

}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# sets the gpg recipient
yadm::gpg::uid-set() {

    local recipient="$1"
    yadm config yadm.gpg-recipient "$recipient"

}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# delete the yadm gpg recipient
yadm::gpg::delete() {

    local uid
    uid="$(yadm::gpg::uid)"
    gpg::primary::delete "$uid" || return 1
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# create the yadm gpg recipient
yadm::gpg::create() {

    local uid
    uid="$(yadm::gpg::uid)"
    gpg::primary::create "$uid" "YADM Encryption Key" || return 1
}
