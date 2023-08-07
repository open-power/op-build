#!/bin/bash
set -xeo pipefail

# used by jenkins processes
WORKSPACE=${WORKSPACE:-${HOME}/op-build}
# allows user to volume mount a op-build repo
opbuild_dir=${1:-${WORKSPACE}/op-build}
# uses git branch name by default 
tag_name=${2:-op-build:$(git rev-parse --abbrev-ref HEAD)}

#--no-cache
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t $tag_name -f ci/ibm/Dockerfile ci/ibm 

# start the environment
containier_id=$(podman run -dit --userns=keep-id -v /home/$USER/.ssh:/home/$USER/.ssh:z $tag_name)

# copy in the required files
podman cp $opbuild_dir $containier_id:op-build

# do the compile
podman exec -w /home/$USER/op-build $containier_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"



