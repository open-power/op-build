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

if [ -z "${OUTDIR}" or ! -d "${OUTDIR}" ]; then
	echo "No output directory specified"
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

if [ -f $(ldconfig -p | grep libeatmydata.so | tr ' ' '\n' | grep /|head -n1) ]; then
    export LD_PRELOAD=${LD_PRELOAD:+"$LD_PRELOAD "}libeatmydata.so
fi

for i in ${DEFCONFIGS[@]}; do
	export O=${OUTDIR}-$i
	rm -rf $O
        op-build O=$O $i
	./buildroot/utils/config --file $O/.config --set-val BR2_CCACHE y
        ./buildroot/utils/config --file $O/.config --set-str BR2_CCACHE_DIR $CCACHE_DIR
	if [ -d "$SDK_DIR" ]; then
	    ./buildroot/utils/config --file $O/.config --set-val BR2_TOOLCHAIN_EXTERNAL y
	    ./buildroot/utils/config --file $O/.config --set-str BR2_TOOLCHAIN_EXTERNAL_PATH $SDK_DIR
	    ./buildroot/utils/config --file $O/.config --set-val BR2_TOOLCHAIN_EXTERNAL_CUSTOM_GLIBC y
	    ./buildroot/utils/config --file $O/.config --set-val BR2_TOOLCHAIN_EXTERNAL_CXX y
	    # FIXME: How do we work this out programatically?
	    ./buildroot/utils/config --file $O/.config --set-val BR2_TOOLCHAIN_EXTERNAL_GCC_6 y
	    ./buildroot/utils/config --file $O/.config --set-val BR2_TOOLCHAIN_EXTERNAL_HEADERS_4_18 y
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

