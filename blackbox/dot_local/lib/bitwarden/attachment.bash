# bitwarden/attachment.bash
# Bitwarden CLI script to upload and download attachments
#
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[ -n "$_BITWARDEN_ATTACHMENT" ] && return 0
_BITWARDEN_ATTACHMENT=1
