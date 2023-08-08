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
echo "podman build took $(($end_time-$start_time)) seconds" > timings.txt

start_time=$(date +%s)
container_id=$(podman run -dit --userns=keep-id \
                -v /home/$USER/.ssh:/home/$USER/.ssh:z \
                -v /home/$USER/.jfrog:/home/$USER/.jfrog:z \
                $tag_name)

end_time=$(date +%s)
echo "podman run took $(($end_time-$start_time)) seconds" >> timings.txt

# copy the repo in. all files now stay inside container
start_time=$(date +%s)
podman cp $opbuild_dir $container_id:$working_dir
end_time=$(date +%s)
echo "cp $opbuild_dir $container_id:$working_dir took $(($end_time-$start_time)) seconds" >> timings.txt

# do the compile

podman exec -w $working_dir $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"
end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build took $(($end_time-$start_time)) seconds" >> timings.txt


# Upload artifacts
start_time=$(date +%s)
podman exec -w $working_dir $container_id /bin/bash -c "./rt_upload.sh"
end_time=$(date +%s)
echo "jf rt u --spec=p10ebmc_upload_spec.txt took $(($end_time-$start_time)) seconds" >> timings.txt


# Stop and remove the container upon successful run
podman stop $container_id 