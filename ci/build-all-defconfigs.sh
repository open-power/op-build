#!/bin/bash

set -ex
set -eo pipefail

BUILD_INFO=0
SDK_ONLY=0
CONFIGTAG="_defconfig"
DEFCONFIGS=();
SDK_DIR=""

opt=$(getopt -o 'o:Ss:p:r' -- "$@")
if [ $? -ne 0 ] ; then
	echo "Invalid arguments"
	exit 1
fi

eval set -- "$opt"
unset opt

while true; do
  case "$1" in
    '-o')
      shift
      echo "Output directory: $1"
      OUTDIR="$1"
      ;;
    '-S')
      echo "Build SDK Only"
      SDK_ONLY=1
      ;;
    '-s')
      shift
      echo "SDK cache dir is in: $1"
      SDK_CACHE=$1
      ;;
    '-p')
      shift
      echo "Platforms to build: $1"
      PLATFORM_LIST="$1"
      ;;
    '-r')
      echo "Build legal-info etc for release"
      BUILD_INFO=1
      ;;
    '--')
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
  shift
done

function get_major_minor_release
{
	IFS=. read major minor macro <<<"$1"
	echo -n "${major}_${minor}"
}

function get_major_release
{
	IFS=. read major minor macro <<<"$1"
	echo -n "${major}"
}

function sha1sum_dir
{
	echo -n "$(find $1 -type f -print0 | sort -z | xargs -0 sha1sum | sed -e 's/ .*//' | tr -d '[:space:]' | sha1sum | sed -e 's/ .*//')"
}

function build_sdk
{
# $1 is the defconfig
# $2 is the SDK output directory
# writes the output SDK pathname in global $SDK_DIR
# also considers global var $CCACHE_DIR
	SDK_BUILD_DIR=`mktemp -d`
	op-build O=$SDK_BUILD_DIR $1

	# Accumulate the SDK properties we want to hash to make it unique, but
	# just so. Start with the buildroot version and machine/OS
	HASH_PROPERTIES="$(git submodule) $(uname -mo)"

	# Even if they should be interchangeable, we want to force the sdk
	# build on every supported OS variations
	HASH_PROPERTIES="$HASH_PROPERTIES $(lsb_release -as | tr -d '[:space:]')"

	# Disable things not necessary for the sdk
	# (Buildroot manual section 6.1.3 plus a few more things)
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --disable INIT_BUSYBOX \
		--enable INIT_NONE \
		--disable SYSTEM_BIN_SH_BUSYBOX \
		--disable TARGET_ROOTFS_TAR \
		--disable SYSTEM_BIN_SH_DASH \
		--enable SYSTEM_BIN_SH_NONE

	# We don't need the Linux Kernel or eudev (they'll be rebuilt anyway), but we need
	# to preserve the custom kernel version (if defined) for headers consistency, and
	# since we're at it,  enabling CPP won't hurt and will make the SDK more general
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --disable LINUX_KERNEL \
		--disable ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV \
		--enable INSTALL_LIBSTDCPP

	# Enable toolchains we'll need to be built as part of the SDK, and make sure we
	# consider them to make the sdk unique
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --package \
		--enable PPE42_TOOLCHAIN --enable HOST_PPE42_GCC --enable HOST_PPE42_BINUTILS

	HASH_PROPERTIES="$HASH_PROPERTIES $(sha1sum_dir openpower/package/ppe42-gcc/)"
	HASH_PROPERTIES="$HASH_PROPERTIES $(sha1sum_dir openpower/package/ppe42-binutils/)"

	# As we are disabling BR2_LINUX_KERNEL, capture Kernel version if any
	# to prevent it from defaulting to the last on olddefconfig
	KERNEL_VER=$(buildroot/utils/config --file $SDK_BUILD_DIR/.config --state LINUX_KERNEL_CUSTOM_VERSION_VALUE)
	if [ "$KERNEL_VER" != "undef" ]; then
		KERNEL="KERNEL_HEADERS_$(get_major_minor_release $KERNEL_VER)"
		buildroot/utils/config --file $SDK_BUILD_DIR/.config --enable "$KERNEL"
	fi

	# Disable packages we won't pull into the SDK to speed it's build
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --package \
		--disable BUSYBOX \
		--disable KEXEC_LITE \
		--disable LINUX_FIRMWARE \
		--disable CRYPTSETUP \
		--disable IPMITOOL \
		--disable LVM2 \
		--disable MDADM \
		--disable NVME \
		--disable PCIUTILS \
		--disable ZLIB \
		--disable LIBZLIB \
		--disable DTC \
		--disable LIBAIO \
		--disable JSON_C \
		--disable ELFUTILS \
		--disable NCURSES \
		--disable POPT \
		--disable DROPBEAR --disable DROPBEAR_CLIENT \
		--disable ETHTOOL \
		--disable IFUPDOWN_SCRIPTS \
		--disable LRZSZ \
		--disable NETCAT \
		--disable RSYNC \
		--disable SUDO \
		--disable KMOD \
		--disable POWERPC_UTILS \
		--disable UTIL_LINUX \
		--disable IPRUTILS

	# Additionally, disable ROOTFS stuff that we won't need
	# Including the OpenPower Packages
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --undefine ROOTFS_USERS_TABLES \
		--undefine ROOTFS_OVERLAY \
		--undefine ROOTFS_POST_BUILD_SCRIPT \
		--undefine ROOTFS_POST_FAKEROOT_SCRIPT \
		--undefine ROOTFS_POST_IMAGE_SCRIPT \
		--undefine ROOTFS_POST_SCRIPT_ARGS \
		--undefine OPENPOWER_PLATFORM \
		--undefine BR2_OPENPOWER_POWER8 \
		--undefine BR2_OPENPOWER_POWER9

	# Enable CCACHE
	buildroot/utils/config --file $SDK_BUILD_DIR/.config --enable CCACHE \
		--set-str CCACHE_DIR $CCACHE_DIR

	op-build O=$SDK_BUILD_DIR olddefconfig

	# Ideally this woulnd't matter, but to be safe, include Kernel
	# Headers and GCC version as part of the SDK Hash, so that we
	# don't have Full builds and SDK builds potentially diverging
	# on the headers/compiler versions each uses
	KERNEL_VER=$(buildroot/utils/config --file $SDK_BUILD_DIR/.config --state DEFAULT_KERNEL_HEADERS)
	HASH_PROPERTIES="$HASH_PROPERTIES $KERNEL_VER"
	echo "SDK KERNEL Version: $KERNEL_VER"
	GCC_VER=$(buildroot/utils/config --file $SDK_BUILD_DIR/.config --state GCC_VERSION)
	echo "SDK GCC Version: $GCC_VER"
	HASH_PROPERTIES="$HASH_PROPERTIES $GCC_VER"

	# sha1sum our properties and check if a matching sdk exists
	# A potential caveat he is if op-build is patching any of the
	# HASH_PROPERTIES content at build time
	HASH_VAL=$(echo -n "$HASH_PROPERTIES" | sha1sum | sed -e 's/ .*//')

	SDK_DIR="$2/toolchain-${HASH_VAL}"

	if [ -e "$SDK_DIR" ]; then
		echo "Acceptable SDK for $i exists in $SDK_DIR - skipping build"
	else
		op-build O=$SDK_BUILD_DIR sdk
		if [ $? -ne 0 ]; then
			rm -rf $SDK_DIR
			return 1
		fi

		# Move sdk to resting location and adjust paths
		mv $SDK_BUILD_DIR $SDK_DIR
		$SDK_DIR/host/relocate-sdk.sh
	fi
	export SDK_DIR
}

if [ -z "${PLATFORM_LIST-}" ]; then
        echo "Using all the defconfigs for all the platforms"
        DEFCONFIGS=`(cd openpower/configs; ls -1 *_defconfig)`
else
        IFS=', '
        for p in ${PLATFORM_LIST};
        do
                DEFCONFIGS+=($p$CONFIGTAG)
        done
fi

if [ -z "${CCACHE_DIR-}" ]; then
	CCACHE_DIR=`pwd`/.op-build_ccache
fi

shopt -s expand_aliases
source op-build-env

if [ -n "${DL_DIR-}" ]; then
	unset BR2_DL_DIR
	export BR2_DL_DIR=${DL_DIR}
fi

if [ -f "$(ldconfig -p | grep libeatmydata.so | tr ' ' '\n' | grep /|head -n1)" ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}libeatmydata.so
elif [ -f "/usr/lib64/nosync/nosync.so" ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}/usr/lib64/nosync/nosync.so
fi

for i in ${DEFCONFIGS[@]}; do
	export O=${OUTDIR}/$i
	rm -rf $O

	SDK_DIR=""
	build_sdk $i $SDK_CACHE
	if [ $? -ne 0 ]; then
		echo "Error building SDK"
		exit 1
	fi

	if [ $SDK_ONLY -ne 0 ]; then
		continue
	fi

        op-build O=$O $i
	buildroot/utils/config --file $O/.config --enable CCACHE \
		--set-str CCACHE_DIR $CCACHE_DIR
	buildroot/utils/config --file $O/.config --enable TOOLCHAIN_EXTERNAL \
		--set-str TOOLCHAIN_EXTERNAL_PATH $SDK_DIR/host \
		--enable TOOLCHAIN_EXTERNAL_CUSTOM_GLIBC

	# Our SDK will always have CPP enabled, but avoid potentially
	# diverging with the Full build by only enabling it
	# conditionally
	CPP_REQUIRED=$(buildroot/utils/config --file $O/.config --state INSTALL_LIBSTDCPP)
	if [ "$CPP_REQUIRED" = "y" ]; then
		buildroot/utils/config --file $O/.config --enable TOOLCHAIN_EXTERNAL_CXX
	fi

	# Our SDK will always have ppe42-toolchain enabled, but
	# only use it if we require it
	PPE42_REQUIRED=$(buildroot/utils/config --file $O/.config --package --state PPE42_TOOLCHAIN)
	if [ "$PPE42_REQUIRED" = "y" ]; then
		buildroot/utils/config --file $O/.config --enable PACKAGE_PPE42_TOOLCHAIN_EXTERNAL \
			--set-str PPE42_TOOLCHAIN_EXTERNAL_PATH $SDK_DIR/host
	fi



	# The Kernel Headers requested MUST be the same as the one
	# provided by the SDK (i.e., it's part of the hash)
	HEADERS_VER=$(buildroot/utils/config --file $O/.config --state TOOLCHAIN_HEADERS_AT_LEAST)
	echo "Toolchain Headers Version Requested: $HEADERS_VER"
	HEADERS="TOOLCHAIN_EXTERNAL_HEADERS_$(get_major_minor_release $HEADERS_VER)"
	buildroot/utils/config --file $O/.config --enable "$HEADERS"

	# Same for the GCC version
	EXTERNAL_GCC_VER=$(buildroot/utils/config --file $O/.config --state GCC_VERSION)
	echo "GCC Version Requested: $EXTERNAL_GCC_VER"
	EXTERNAL_GCC="TOOLCHAIN_EXTERNAL_GCC_$(get_major_release $EXTERNAL_GCC_VER)"
	buildroot/utils/config --file $O/.config --enable "$EXTERNAL_GCC"

        op-build O=$O olddefconfig
        op-build O=$O
        r=$?
	if [ ${BUILD_INFO} -eq 1 ] && [ $r -eq 0 ]; then
	    op-build O=$O legal-info
	    op-build O=$O graph-build
	    op-build O=$O graph-size
	    op-build O=$O graph-depends
	fi
	lsb_release -a > $O/lsb_release
        if [ $r -ne 0 ]; then
        	exit $r
        fi
done

