#!/usr/bin/env bash
# realms/pull.do
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
readonly MANI_YAML=mani.yaml


# if mani.yaml is not present, download it
if [ ! -f $MANI_YAML ]; then
    bw-pull-file.sh mani.main mani.yaml ./mani.yaml 1>&2
fi
