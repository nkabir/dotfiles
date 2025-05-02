# gpg/core.bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# This script provides functions to manage GPG keys, including creating,
# deleting, and exporting keys. It also includes a function to retrieve
# the fingerprint of a GPG key associated with a given email address.

GPG_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${GPG_HERE:?}/logger.bash"

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
gpg::create-key-pair() {
  local real_name="$1"
  local email="$2"

  if [[ -z "$real_name" || -z "$email" ]]; then
      logger::error "Usage: gpg::create-key-pair \"Real Name\" \"email@example.com\""
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
    local fingerprint="$1"
    if [[ -z "$fingerprint" ]]; then
        echo "Usage: gpg::delete-key-pair "
        return 1
    fi

    # Check if the key pair exists
    if ! gpg --list-keys "$fingerprint" &>/dev/null || ! gpg --list-secret-keys "$fingerprint" &>/dev/null; then
        echo "Key pair with fingerprint $fingerprint does not exist."
        return 1
    fi

    # Delete the key pair
    echo "Deleting GPG secret key for: $fingerprint"
    gpg --yes --batch --delete-secret-keys "$fingerprint"
    if [[ $? -ne 0 ]]; then
        echo "Failed to delete secret key with fingerprint $fingerprint (it may not exist)."
    fi

    echo "Deleting GPG public key for: $fingerprint"
    gpg --yes --batch --delete-keys "$fingerprint"
    if [[ $? -ne 0 ]]; then
        echo "Failed to delete public key with fingerprint $fingerprint (it may not exist)."
    fi

    # Verify removal
    echo "Verifying removal..."
    gpg --list-secret-keys "$fingerprint"
    gpg --list-keys "$fingerprint"
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
gpg::get-fingerprint() {
    local email="$1"
    if [[ -z "$email" ]]; then
        echo "Usage: gpg::get-fingerprint "
        return 1
    fi

    gpg --with-colons --fingerprint "$email" | awk -F: '/^fpr:/ {print $10; exit}'
}
