#!/bin/bash

set -ex
set -eo pipefail

BUILD_INFO=0
CONFIGTAG="_defconfig"

DEFCONFIGS=();

while getopts "o:p:r" opt; do
  case $opt in
    o)
      echo "Output directory: $OPTARG"
      OUTDIR="$OPTARG"
      ;;
    p)
      echo "Platforms to build: $OPTARG"
      PLATFORM_LIST="$OPTARG"
      ;;
    r)
      echo "Build legal-info for release"
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

for i in ${DEFCONFIGS[@]}; do
        rm -rf output/*
        op-build $i
        echo 'BR2_CCACHE=y' >> output/.config
        echo "BR2_CCACHE_DIR=\"$CCACHE_DIR\"" >> output/.config
        echo 'BR2_CCACHE_INITIAL_SETUP=""' >> output/.config

        op-build olddefconfig
        op-build
        r=$?

        if [ ${BUILD_INFO} = 1 ] && [ $r = 0 ]; then
                op-build legal-info
                mv output/legal-info ${OUTDIR}/$i-legal-info
        fi

        mkdir ${OUTDIR}/$i-images
        mv output/images/* ${OUTDIR}/$i-images/
        mv output/.config ${OUTDIR}/$i-images/.config
        lsb_release -a > ${OUTDIR}/$i-images/lsb_release
        if [ $r -ne 0 ]; then
        	exit $r
        fi
done

