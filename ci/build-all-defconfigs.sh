#!/bin/bash

set -ex
set -eo pipefail

DEFCONFIGS=`(cd openpower/configs; ls -1 *_defconfig)`

if [ -z "$1" or ! -d "$1" ]; then
	echo "No output directory specified"
	exit 1;
fi

if [ -z "$CCACHE_DIR" ]; then
	CCACHE_DIR=`pwd`/.op-build_ccache
fi

shopt -s expand_aliases
source op-build-env

for i in $DEFCONFIGS; do
        op-build $i
        echo 'BR2_CCACHE=y' >> output/.config
        echo "BR2_CCACHE_DIR=\"$CCACHE_DIR\"" >> output/.config
        echo 'BR2_CCACHE_INITIAL_SETUP=""' >> output/.config

        op-build olddefconfig
        op-build
        r=$?
        mkdir $1/$i-images
        mv output/images/* $1/$i-images/
        mv output/.config $1/$i-images/.config
	lsb_release -a > $1/$i-images/lsb_release
        rm -rf output/*
        if [ $r -ne 0 ]; then
        	exit $r
        fi
done

