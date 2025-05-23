# rage/core.bash
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
[[ -n "$_RAGE_CORE" ]] && return 0
_RAGE_CORE=1

RAGE_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Load the rage functions
. "${RAGE_HERE:?}/../logger/core.bash"


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
rage::keygen() {

    rage-keygen

}
export -f rage::keygen

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# rage::encrypt
# Usage: rage::encrypt <age-recipient-or-key> <plaintext>
# Encrypts the given plaintext using the provided age recipient (public key or passphrase)
rage::encrypt() {
    local key="$1"
    local plaintext="$2"

    if [[ -z "$key" || -z "$plaintext" ]]; then
        logger::error "Usage: rage::encrypt <age-recipient-or-key> <plaintext>"
        return 2
    fi

    # If the key starts with "age1", treat as recipient public key; otherwise, treat as passphrase
    if [[ "$key" =~ ^age1 ]]; then
        echo -n "$plaintext" | rage -e -r "$key"
    else
        echo -n "$plaintext" | rage -e -p --passphrase="$key"
    fi
}
export -f rage::encrypt


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
# rage::decrypt
# Usage: rage::decrypt <age-key-or-passphrase> <ciphertext>
# Decrypts the given ciphertext using the provided age key (private key file, or passphrase)
rage::decrypt() {
    local key="$1"
    local ciphertext="$2"

    if [[ -z "$key" || -z "$ciphertext" ]]; then
        logger::error "Usage: rage::decrypt <age-key-or-passphrase> <ciphertext>"
        return 2
    fi

    # If the key starts with "age1", treat as identity file; otherwise, treat as passphrase
    if [[ "$key" =~ ^age1 ]]; then
        echo -n "$ciphertext" | rage -d -i "$key"
    else
        echo -n "$ciphertext" | rage -d -p --passphrase="$key"
    fi
}
export -f rage::decrypt
