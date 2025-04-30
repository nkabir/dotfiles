# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::create-key-pair() {
  local real_name="$1"
  local email="$2"

  if [[ -z "$real_name" || -z "$email" ]]; then
    echo "Usage: gpg::create-key-pair \"Real Name\" \"email@example.com\""
    return 1
  fi

  # Create a temporary batch file for GPG key parameters
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

  # Generate the key
  gpg --batch --generate-key "$batch_file"

  # Clean up
  rm -f "$batch_file"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::delete-key-pair() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::delete-key-pair-by-email <email-address>"
        return 1
    fi

    echo "Deleting GPG secret key for: $email"
    gpg --yes --delete-secret-keys "$email"
    if [[ $? -ne 0 ]]; then
        echo "Failed to delete secret key for $email (it may not exist)."
    fi

    echo "Deleting GPG public key for: $email"
    gpg --yes --delete-keys "$email"
    if [[ $? -ne 0 ]]; then
        echo "Failed to delete public key for $email (it may not exist)."
    fi

    echo "Verifying removal..."
    gpg --list-secret-keys "$email"
    gpg --list-keys "$email"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::export-private-key() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::export-armored-private-key <email-address>"
        return 1
    fi

    gpg --armor --export-secret-keys "$email"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::export-public-key() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::export-public-key <email-address>"
        return 1
    fi

    gpg --armor --export "$email"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::key-pair-exists() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::key-pair-exists <email-address>"
        return 2
    fi

    # Check for public key
    if ! gpg --list-keys "$email" &>/dev/null; then
        return 1
    fi

    # Check for private key
    if ! gpg --list-secret-keys "$email" &>/dev/null; then
        return 1
    fi

    # Both keys exist
    return 0
}
