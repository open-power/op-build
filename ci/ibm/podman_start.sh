#!/bin/bash

#--no-cache
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t demo:v1 -f ci/ibm/Dockerfile ci/ibm 

#podman run -it --userns=keep-id -v /home/$USER/op-build-dlarson:/home/$USER/op-build:z -v /home/$USER/.ssh:/home/$USER/.ssh:z -w /home/$USER/op-build demo:v1
containier_id=$(podman run -dit --userns=keep-id -v /home/$USER/op-build-dlarson:/home/$USER/op-build:z -v /home/$USER/.ssh:/home/$USER/.ssh:z -w /home/$USER/op-build demo:v1)

echo "./op-build p10ebmc_defconfig && ./op-build source && ./op-build toolchain"
start=$(date +%s)
podman exec -e BUILD_TOOLCHAIN=1 -w /home/$USER/op-build $containier_id /bin/bash -c ". op-build-env && ./op-build p10ebmc_defconfig && ./op-build source && ./op-build toolchain"
end=$(date +%s)
echo "Elapsed Time: $(($end-$start)) seconds"

echo "./op-build"
start=$(date +%s)
podman exec -w /home/$USER/op-build $containier_id /bin/bash -c "./op-build"
end=$(date +%s)
echo "Elapsed Time: $(($end-$start)) seconds"

echo "op-build compile completed"