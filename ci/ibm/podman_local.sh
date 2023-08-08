#!/bin/bash
set -xeo pipefail

# allows user to volume mount a op-build repo
opbuild_dir=${1:-${HOME}/op-build}
# uses git branch name by default 
tag_name=${2:-op-build:$(git rev-parse --abbrev-ref HEAD)}

working_dir=/home/$USER/op-build
#exit
#--no-cache
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t $tag_name -f ci/ibm/Dockerfile ci/ibm 

# mount the local repo into the container
# mount ssh keys for additional cloning if required
container_id=$(podman run -itd --userns=keep-id \
                -v $opbuild_dir:$working_dir:z \
                -v /home/$USER/.ssh:/home/$USER/.ssh:z \
                -v /home/$USER/.jfrog:/home/$USER/.jfrog:z \
                -w $working_dir $tag_name)

# do the compile
podman exec -w $working_dir $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"


