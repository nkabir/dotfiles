#!/bin/bash
# realms/push.do
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::
readonly MANI_YAML=mani.yaml

if [ -f $MANI_YAML ]; then
    bw-push-file.sh mani.main $MANI_YAML ./$MANI_YAML 1>&2
fi
