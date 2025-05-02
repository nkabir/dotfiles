# bitwarden/note.bash
# This script is used to create a note in Bitwarden
# It requires the Bitwarden CLI to be installed and configured.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_NOTE" ] && return 0
_BITWARDEN_NOTE=1
