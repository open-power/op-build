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
./buildroot/utils/config --file $O/.config --enable CCACHE
./buildroot/utils/config --file $O/.config --set-str CCACHE_DIR $CCACHE_DIR

# Disable things not necessary for the sdk
# (Buildroot manual section 6.1.3)
./buildroot/utils/config --file $O/.config --disable INIT_BUSYBOX \
	--enable INIT_NONE \
	--disable SYSTEM_BIN_SH_BUSYBOX \
	--disable TARGET_ROOTFS_TAR

# Additionally, disable OpenPower packages and
# ROOTFS stuff that we won't need
./buildroot/utils/config --file $O/.config --disable OPENPOWER_PLATFORM \
	--undefine ROOTFS_USERS_TABLES \
	--undefine ROOTFS_OVERLAY \
	--undefine ROOTFS_POST_BUILD_SCRIPT \
	--undefine ROOTFS_POST_FAKEROOT_SCRIPT \
	--undefine ROOTFS_POST_IMAGE_SCRIPT \
	--undefine ROOTFS_POST_SCRIPT_ARGS

op-build O=$O olddefconfig

if [ -f "$(ldconfig -p | grep libeatmydata.so | tr ' ' '\n' | grep /|head -n1)" ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}libeatmydata.so
elif [ -f "/usr/lib64/nosync/nosync.so" ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}/usr/lib64/nosync/nosync.so
fi

op-build O=$O sdk
