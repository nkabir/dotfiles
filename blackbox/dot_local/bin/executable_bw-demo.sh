#!/usr/bin/env bash
# bin/bw-demo.sh
# shellcheck shell=bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
set -eo pipefail


HERE="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" \
    &> /dev/null && pwd 2> /dev/null; )";

# logout                                      Log out of the current user account.
# lock                                        Lock the vault and destroy active session keys.
# sync [options]                              Pull the latest vault data from server.
# login [options] [email] [password]          Log into a user account.
# unlock [options] [password]                 Unlock the vault and return a new session key.
# status                                      Show server, last sync, user information, and vault status.
# sdk-version                                 Print the SDK version.
# generate [options]                          Generate a password/passphrase.
# encode                                      Base 64 encode stdin.
# config [options] <setting> [value]          Configure CLI settings.
# update                                      Check for updates.
# completion [options]                        Generate shell completions.
# list [options] <object>                     List an array of objects from the vault.
# get [options] <object> <id>                 Get an object from the vault.
# create [options] <object> [encodedJson]     Create an object in the vault.
# edit [options] <object> <id> [encodedJson]  Edit an object from the vault.

# delete [options] <object> <id>              Delete an object from the vault.

# restore <object> <id>                       Restores an object from the trash.
# move <id> <organizationId> [encodedJson]    Move an item to an organization.
# confirm [options] <object> <id>             Confirm an object to the organization.
# import [options] [format] [input]           Import vault data from a file.
# export [options]                            Export vault data to a CSV or JSON file.
# share <id> <organizationId> [encodedJson]   --DEPRECATED-- Move an item to an organization.
# send [options] <data>                       Work with Bitwarden sends. A Send can be quickly created using this command or subcommands can be used to fine-tune the Send
# receive [options] <url>                     Access a Bitwarden Send from a url
# serve [options]                             Start a RESTful API webserver.
# help [command]                              display help for command


. "${HERE:?}/../gig/bitwarden/core.bash"


# @cmd login into Bitwarden
# @alias 1
login() {

    gig::bitwarden::login
}



eval "$(argc --argc-eval "$0" "$@")"
