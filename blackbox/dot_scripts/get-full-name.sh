#!/usr/bin/env bash
# return the full name of the current user

readonly USER_NAME=$(whoami)
# get full name
readonly FULL_NAME=$(getent passwd "$USER_NAME" | cut -d: -f5 | cut -d, -f1)
printf "%s" "$FULL_NAME"
