# gpg/primary.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Add this function to gpg/core.bash or an appropriate gpg library file

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# gpg::primary::create
# Creates a new GPG key pair given a real name and email
# Usage: gpg::primary::create "Real Name" "email@example.com"
gpg::primary::create() {
    local real_name="$1"
    local email="$2"

    if [[ -z "$real_name" || -z "$email" ]]; then
        logger::error "Usage: gpg::primary::create \"Real Name\" \"email@example.com\""
        return 1
    fi

    # Create a temporary batch file with key parameters for unattended generation
    local batch_file
    batch_file=$(mktemp)

    cat > "$batch_file" <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: $real_name
Name-Email: $email
Expire-Date: 0
%no-protection
%commit
EOF

    logger::info "Generating new GPG key for $real_name <$email>"
    if gpg --batch --generate-key "$batch_file"; then
        logger::info "Successfully created GPG key pair for $email"
        rm -f "$batch_file"
        return 0
    else
        logger::error "Failed to create GPG key pair for $email"
        rm -f "$batch_file"
        return 1
    fi
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Delete a GPG key pair
gpg::primary::delete() {
  local uid="$1"
  if [[ -z "$uid" ]]; then
    logger::error "Usage: gpg::primary::delete <uid>"
    return 1
  fi

  logger::info "Deleting GPG secret key for UID: $uid"
  gpg --batch --yes --delete-secret-key "$uid"
  logger::info "Deleting GPG public key for UID: $uid"
  gpg --batch --yes --delete-key "$uid"
}
