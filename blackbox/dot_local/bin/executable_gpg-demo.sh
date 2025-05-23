#!/usr/bin/env bash
# gpg-demo.sh

GPG_DEMO_HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

. "${GPG_DEMO_HERE}/../lib/gpg.bash"

# This script demonstrates how to use GPG for encryption and decryption
# of files and messages. It also shows how to generate a key pair
# and how to import and export keys.
# It is assumed that you have GPG installed and configured on your system.
# The script uses the GPG command line interface to perform the operations.
# The script is intended for educational purposes and should not be used
# for production use without proper security considerations.
# The script is licensed under the MIT License.


DEMO_KEY="seed-gpg@local"
FINGERPRINT=$(gpg::get-fingerprint "${DEMO_KEY}")

echo "Fingerprint: ${FINGERPRINT}"
