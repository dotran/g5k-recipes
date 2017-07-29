#!/usr/bin/env bash

ROOT_PROJECT=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
BUILD_PATH=${TARGET:-$PWD}/build
ROOTFS_PATH=${TARGET:-$PWD}/rootfs
FORMAT=tgz

trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    echo "** Exited"
    exit 1
}


if [ -z "$1" ]; then
    RECIPES=*.yaml
else
    RECIPES="$@"
fi

if [ ! -z "$HTTP_PROXY" ]; then
    PROXY="--proxy $(echo $HTTP_PROXY | awk -F/ '{print $3}')"
fi


for r in $RECIPES; do
    name=$(basename $r .yaml)
    if [ -e "$ROOTFS_PATH/${name}.$FORMAT" -a -z "$FORCE" ]; then
      echo "$ROOTFS_PATH/${name}.$FORMAT already exists"
    else
        rm -rf $BUILD_PATH
        cat <<EOF
===============================================================================
=== $name
===============================================================================
EOF
        
        (set -x; kameleon build $ROOT_PROJECT/$r --build-path \
                    $BUILD_PATH --script --enable-cache --cache-archive-compression=none --global=appliance_formats:$FORMAT $PROXY)
        
        if [ $? -ne 0 ]; then
            echo -e "\n$name FAILED\n"
        fi
    fi
done
