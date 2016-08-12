#!/bin/bash

while getopts ":ahp:" opt; do
  case $opt in
    a)
      echo "Build firmware images for all platforms"
      TEMP=""
      ;;
    p)
      echo "Build firmware images for the platform: $OPTARG"
      TEMP=$OPTARG
      ;;
    h)
      echo "Usage: ./ci/build.sh [options] [--]"
      echo "-h          Print this help and exit successfully."
      echo "-a          Build firmware images for all the platform defconfig's."
      echo "-p          Platform name as parameter to build firmware images for particular platform."
      echo "Example:./ci/build.sh -a"
      echo -e "\t./ci/build.sh -p firestone"
      echo -e "\t./ci/build.sh -p garrison"
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

set -ex
set -eo pipefail

function run_docker
{
	$DOCKER_PREFIX docker run --cap-add=sys_admin --net=host --rm=true \
	 --user="${USER}" -w "${PWD}" -v "${PWD}":"${PWD}":Z \
         -t $1 $2
}

env

if [ -d output-images ]; then
	echo 'output-images already exists!';
	exit 1;
fi

for distro in ubuntu1404 fedora23;
do
	base_dockerfile=ci/Dockerfile/$distro.`arch`
	if [ ! -f $base_dockerfile ]; then
	  echo '$distro not supported on `arch`.';
	  continue
	fi
	if [[ -n "$HTTP_PROXY" ]]; then
		http_proxy=$HTTP_PROXY
	fi
	if [[ -n "$http_proxy" ]]; then
	  if [[ "$distro" == fedora23 ]]; then
	    PROXY="RUN echo \"proxy=${http_proxy}\" >> /etc/dnf/dnf.conf"
	  fi
	  if [[ "$distro" == ubuntu1404 ]]; then
	    PROXY="RUN echo \"Acquire::http::Proxy \\"\"${http_proxy}/\\"\";\" > /etc/apt/apt.conf.d/000apt-cacher-ng-proxy"
	  fi
        fi

	Dockerfile=$(head -n1 $base_dockerfile; echo ${PROXY}; tail -n +2 $base_dockerfile; cat << EOF
RUN groupadd -g ${GROUPS} ${USER} && useradd -d ${HOME} -m -u ${UID} -g ${GROUPS} ${USER}
${PROXY}
USER ${USER}
ENV HOME ${HOME}
EOF
)
	$DOCKER_PREFIX docker build -t openpower/op-build-$distro - <<< "${Dockerfile}"
	mkdir -p output-images/$distro
	run_docker openpower/op-build-$distro "./ci/build-all-defconfigs.sh output-images/$distro $TEMP"
	if [ $? = 0 ]; then
		mv *-images output-$distro/
	else
		exit $?;
	fi
done;

