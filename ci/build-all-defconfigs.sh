#!/bin/bash

set -ex
set -eo pipefail

BUILD_INFO=0
CONFIGTAG="_defconfig"

DEFCONFIGS=();

SDK_DIR=""

while getopts "o:p:rs:" opt; do
  case $opt in
    o)
      echo "Output directory: $OPTARG"
      OUTDIR="$OPTARG"
      ;;
    s)
      echo "SDK is in: $OPTARG"
      SDK_DIR=$OPTARG
      ;;
    p)
      echo "Platforms to build: $OPTARG"
      PLATFORM_LIST="$OPTARG"
      ;;
    r)
      echo "Build legal-info etc for release"
      BUILD_INFO=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

function get_kernel_release
{
	IFS=. read major minor macro <<<"$1"
	echo -n "${major}_${minor}"
}

if [ -z "${PLATFORM_LIST}" ]; then
        echo "Using all the defconfigs for all the platforms"
        DEFCONFIGS=`(cd openpower/configs; ls -1 *_defconfig)`
else
        IFS=', '
        for p in ${PLATFORM_LIST};
        do
                DEFCONFIGS+=($p$CONFIGTAG)
        done
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

if [ -f "$(ldconfig -p | grep libeatmydata.so | tr ' ' '\n' | grep /|head -n1)" ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}libeatmydata.so
fi

for i in ${DEFCONFIGS[@]}; do
	export O=${OUTDIR}/$i
	rm -rf $O
        op-build O=$O $i
	./buildroot/utils/config --file $O/.config --enable BR2_CCACHE
        ./buildroot/utils/config --file $O/.config --set-str BR2_CCACHE_DIR $CCACHE_DIR
	if [ -d "$SDK_DIR" ]; then
	    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL
	    ./buildroot/utils/config --file $O/.config --set-str BR2_TOOLCHAIN_EXTERNAL_PATH $SDK_DIR
	    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL_CUSTOM_GLIBC
	    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL_CXX
	    if [ "$(./buildroot/utils/config --file $O/.config --state GCC_VERSION_6_X)" == "y" ]; then
		    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL_GCC_6
	    elif [ "$(./buildroot/utils/config --file $O/.config --state GCC_VERSION_7_X)" == "y" ]; then
		    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL_GCC_7
	    elif [ "$(./buildroot/utils/config --file $O/.config --state GCC_VERSION_8_X)" == "y" ]; then
		    ./buildroot/utils/config --file $O/.config --enable BR2_TOOLCHAIN_EXTERNAL_GCC_8
	    fi
	    KERNEL_VER=$(./buildroot/utils/config --file $O/.config --state BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE)
	    echo "KERNEL_VER " $KERNEL_VER
	    HEADERS=BR2_TOOLCHAIN_EXTERNAL_HEADERS_$(get_kernel_release $KERNEL_VER)
	    ./buildroot/utils/config --file $O/.config --enable $HEADERS
	fi
        op-build O=$O olddefconfig
        op-build O=$O
        r=$?
	if [ ${BUILD_INFO} = 1 ] && [ $r = 0 ]; then
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

