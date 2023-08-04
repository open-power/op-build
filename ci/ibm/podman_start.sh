#!/bin/bash

#--no-cache
podman build --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t op-build:demo -f ci/ibm/Dockerfile ci/ibm 

#podman run -it --userns=keep-id -v /home/$USER/op-build-dlarson:/home/$USER/op-build:z -v /home/$USER/.ssh:/home/$USER/.ssh:z -w /home/$USER/op-build demo:v1
containier_id=$(podman run -dit --userns=keep-id -v /home/$USER/op-build-dlarson:/home/$USER/op-build:z -v /home/$USER/.ssh:/home/$USER/.ssh:z -w /home/$USER/op-build demo:v1)

start_time=$(date +%s)
podman exec -w /home/$USER/op-build $containier_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build source"
end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build source" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt


start_time=$(date +%s)
podman exec -e BUILD_TOOLCHAIN=1 -w /home/$USER/op-build $containier_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build toolchain"
end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build toolchain" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt


start_time=$(date +%s)
podman exec -w /home/$USER/op-build $containier_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"
end_time=$(date +%s)
echo "./op-build" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt

cat timings.txt
