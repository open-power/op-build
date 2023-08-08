#!/bin/bash

tag_name=op-build:$(git rev-parse --abbrev-ref HEAD)
#--no-cache
podman build --no-cache --build-arg UID=$UID --build-arg GID=$(id -g) --build-arg USER=$USER -t $tag_name -f ci/ibm/Dockerfile ci/ibm 



#podman run -it --userns=keep-id -v /home/$USER/op-build-dlarson:/home/$USER/op-build:z -v /home/$USER/.ssh:/home/$USER/.ssh:z -w /home/$USER/op-build demo:v1
container_id=$(podman run -dit --userns=keep-id -v /home/$USER/.ssh:/home/$USER/.ssh:z $tag_name)

# download
start_time=$(date +%s)

podman cp $WORKSPACE/op-build $container_id:op-build

end_time=$(date +%s)
echo "cp $WORKSPACE/op-build $container_id:op-build | $(($end_time-$start_time)) seconds" > timings.txt
echo "Elapsed Time: " >> timings.txt


# downloads
start_time=$(date +%s)

podman exec -w /home/$USER/op-build $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build source"

end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build source" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt

# toolchain
start_time=$(date +%s)

podman exec -e BUILD_TOOLCHAIN=1 -w /home/$USER/op-build $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build toolchain"

end_time=$(date +%s)
echo "./op-build p10ebmc_defconfig && ./op-build toolchain" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt


# do the compile
start_time=$(date +%s)

podman exec -w /home/$USER/op-build $container_id /bin/bash -c "./op-build p10ebmc_defconfig && ./op-build"

end_time=$(date +%s)
echo "./op-build" >> timings.txt
echo "Elapsed Time: $(($end_time-$start_time)) seconds" >> timings.txt


cat timings.txt
