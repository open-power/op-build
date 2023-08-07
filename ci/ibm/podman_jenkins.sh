#!/bin/bash
set -xeo pipefail

# used by jenkins processes
WORKSPACE=${WORKSPACE:-${HOME}}
# allows user to volume mount a op-build repo
opbuild_dir=${1:-${WORKSPACE}/op-build}
# uses git branch name by default 
tag_name=${2:-op-build:$(git rev-parse --abbrev-ref HEAD)}

working_dir=/home/$USER/op-build

#--no-cache
start_time=$(date +%s)
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t $tag_name -f ci/ibm/Dockerfile ci/ibm
end_time=$(date +%s)
echo "podman build\n$(($end_time-$start_time)) took seconds" > timings.txt

start_time=$(date +%s)
containier_id=$(podman run -dit --userns=keep-id -v /home/$USER/.ssh:/home/$USER/.ssh:z $tag_name)
end_time=$(date +%s)
echo "podman run took seconds" >> timings.txt

start_time=$(date +%s)
podman cp $opbuild_dir $containier_id:$working_dir
end_time=$(date +%s)
echo "cp $opbuild_dir $containier_id:$working_dir $(($end_time-$start_time)) took seconds" >> timings.txt

# do the compile
start_time=$(date +%s)
podman exec -w $working_dir $containier_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"
end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build $(($end_time-$start_time)) took seconds" >> timings.txt
