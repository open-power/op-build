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
container_id=$(podman run -dit --userns=keep-id \
                -v /home/$USER/.ssh:/home/$USER/.ssh:z \
                -v /home/$USER/.jfrog:/home/$USER/.jfrog:z \ 
                $tag_name)
end_time=$(date +%s)
echo "podman run took seconds" >> timings.txt

# copy the repo in. all files now stay inside container
start_time=$(date +%s)
podman cp $opbuild_dir $container_id:$working_dir
end_time=$(date +%s)
echo "cp $opbuild_dir $container_id:$working_dir $(($end_time-$start_time)) took seconds" >> timings.txt

# do the compile
start_time=$(date +%s)
podman exec -w $working_dir $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"
end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build $(($end_time-$start_time)) took seconds" >> timings.txt

# now set up jfrog cli setting to upload
podman exec -w $working_dir $container_id /bin/bash -c "cat jfrog_rt_access_token | jf c add \
        --interactive=false \
        --user=hostboot@us.ibm.com \
        --url=https://na-public.artifactory.swg-devops.com \
        --access-token-stdin=true \
        na-artifactory"

# Upload artifacts
podman exec -w $working_dir $container_id /bin/bash -c "./rt_upload.sh"

# Stop and remove the container upon successful run
podman stop $container_id 