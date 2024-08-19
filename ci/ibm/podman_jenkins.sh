#!/bin/bash
set -xeo pipefail

# used by jenkins processes
WORKSPACE=${WORKSPACE:-${HOME}}
# allows user to volume mount a op-build repo
opbuild_dir=${1:-${WORKSPACE}/op-build}
# uses git branch name by default 
local_tag=${2:-op-build:pr-${CHANGE_ID}}
# create unique tag for artifactory
remote_tag=${3:-docker-na-public.artifactory.swg-devops.com/pse-jet-docker-local/op-build/pr-${CHANGE_ID}:${BUILD_NUMBER}}
latest_tag=${4:-docker-na-public.artifactory.swg-devops.com/pse-jet-docker-local/op-build/pr-${CHANGE_ID}:latest}

working_dir=/home/$USER/op-build

#--no-cache
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t $local_tag -f ci/ibm/Dockerfile ci/ibm

# start the environment in the background
container_id=$(podman run -dit --userns=keep-id \
                -e BUILD_NUMBER=$BUILD_NUMBER \
                -e CHANGE_ID=$CHANGE_ID \
                -v /home/$USER/.ssh:/home/$USER/.ssh:z \
                -v /home/$USER/.jfrog:/home/$USER/.jfrog:z \
                $local_tag)

# copy the repo in. all files now stay inside container
podman cp $opbuild_dir $container_id:$working_dir

# do the compile
#podman exec -w $working_dir $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"
podman exec -w $working_dir $container_id /bin/bash -c "./op-build p10ebmc_defconfig"

# Upload build images to artifactory
podman exec -w $working_dir $container_id /bin/bash -c "./ci/ibm/upload_artifactory.sh"
podman cp $container_id:$working_dir/upload.log $WORKSPACE
echo "Browse https://na-public.artifactory.swg-devops.com/ui/native/pse-jet-sys-powerfw-generic-local/op-build/pr-$CHANGE_ID/$BUILD_NUMBER"


# create unique tag for artifactory
podman commit $container_id $remote_tag
podman tag $remote_tag $latest_tag

# push to artifactory to save this version of the environment
podman push $remote_tag
podman push $latest_tag
echo "Browse tags https://na-public.artifactory.swg-devops.com/ui/native/pse-jet-docker-local/op-build/pr-$CHANGE_ID"

echo "To recreate podman run -itd --userns=keep-id --user hostboot -v /home/$USER/.ssh:/home/$USER/.ssh:z -v /home/$USER/.jfrog:/home/$USER/.jfrog:z -w $working_dir $remote_tag"


start_time=$(date +%s)
# Stop and remove the container upon successful run
podman stop $container_id
end_time=$(date +%s)
echo "podman stop took $(($end_time-$start_time)) seconds" >> timings.txt