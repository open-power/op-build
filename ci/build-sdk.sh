#!/bin/bash

set -ex
set -eo pipefail

if [ -z "$1" ]; then
	echo "No build distro specified"
	exit 1;
fi

if [ -z "$2" ]; then
	echo "No defconfig to build SDK from specified"
	exit 1;
fi

if [ -z "$CCACHE_DIR" ]; then
	CCACHE_DIR=`pwd`/.op-build_ccache
fi

shopt -s expand_aliases
source op-build-env

if [ -n "$DL_DIR" ]; then
	unset BR2_DL_DIR
	export BR2_DL_DIR=${DL_DIR}
fi

export O=`pwd`/output-$1-$2/
op-build O=$O $2
./buildroot/utils/config --file $O/.config --set-val BR2_CCACHE y
./buildroot/utils/config --file $O/.config --set-str BR2_CCACHE_DIR $CCACHE_DIR
op-build O=$O olddefconfig
op-build O=$O sdk
