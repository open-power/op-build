#!/bin/bash

OS="fedora"
agent_os="FEDORA"
CONFIG="p10ebmc"
export FROG_CLI_LOG_LEVEL='ERROR'

####### OUTPUT RE-DIRECTION #######

# Define some variables
op_build_path=$HOME/op-build
origin=$op_build_path/output
destination=$HOME/op-build/build/output_img/$agent_os/$CONFIG/output
powerpc_dir="$destination/host/powerpc64le-buildroot-linux-gnu/sysroot"

# Make needed directories
mkdir -p $destination/images
mkdir -p $powerpc_dir/openpower_pnor_scratch
mkdir -p $powerpc_dir/sbe_sim_data

# Copy required files
cp $origin/images/*.pnor $destination/images/
cp $origin/images/*.pnor.ubi.mtd $destination/images/
cp $origin/images/*.pnor.squashfs.tar $destination/images/
cp $origin/images/*ebmc_lids.tar.gz $destination/images/

# hostboot simics files + tools
cp $origin/images/host_fw_debug.tar $destination/images
cp $origin/images/sim/hostboot_sim.tar $destination/images

# only need the tar.gz and uncompress when needed?
cp $origin/images/mmc.tar.gz $destination/images
cp -r $origin/images/mmc $destination/images

# for opal
cp $origin/host/powerpc64le-buildroot-linux-gnu/sysroot/openpower_pnor_scratch/BOOTKERNEL.bin $powerpc_dir/openpower_pnor_scratch

# sbe simics files + tools
# this is a directory, get all of it. not expecting any child directories
cp $origin/host/powerpc64le-buildroot-linux-gnu/sysroot/sbe_sim_data/* $powerpc_dir/sbe_sim_data

# .config
cp $origin/.config $op_build_path/build/output_img/$agent_os/$CONFIG/p10ebmc.config

# upload to artifactory
echo "{\"files\": [{\"pattern\": \"build/output_img/**/*\",	\"target\": \"pse-jet-sys-powerfw-generic-local/op-build/pr-$CHANGE_ID/$BUILD_NUMBER/\", \"flat\": \"false\"}]} > ci/ibm/p10ebmc_upload_spec.txt

jf rt u --spec=ci/ibm/p10ebmc_upload_spec.txt >> upload.log
#jf rt u build/output_img/**/* pse-jet-sys-powerfw-generic-local/op-build/pr-$CHANGE_ID/$BUILD_NUMBER/ >> upload.log
