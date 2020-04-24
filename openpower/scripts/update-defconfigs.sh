#!/bin/bash -x

set -uo pipefail

. op-build-env

for c in openpower/configs/*defconfig; do
	PLATFORM=`basename $c _defconfig`
	PLATFORM_DEFCONFIG=`basename $c`
	echo $PLATFORM
	ODIR=`mktemp -d`
	op-build O=$ODIR $PLATFORM_DEFCONFIG
	if [ $# -gt 0 ]; then
		buildroot/utils/config --file $ODIR/.config "$@"
	fi
	op-build O=$ODIR olddefconfig
	op-build O=$ODIR savedefconfig
	rm -rf $ODIR
done

git diff --exit-code
