unset CDPATH

# add CDPATH components here
# labkey adds its own

CDPATH=.:${HOME}:${HOME}/labkey:${HOME}/labkey/bench:${HOME}/labkey/bench/xglass
CDPATH=${CDPATH}:${LABKEY_DA:?}/bench/xpkg/rkx/unstable
CDPATH=${CDPATH}:${LABKEY_DA:?}/bench/xpkg/meet175/unstable
CDPATH=${CDPATH}:${LABKEY_DA:?}/bench/xpkg/bulltrout/unstable

export CDPATH
