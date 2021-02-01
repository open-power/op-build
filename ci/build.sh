#!/bin/bash

set -ex
set -eo pipefail

CONTAINERS="ubuntu2004 fedora32"
SDK_ONLY=0

opt=$(getopt -o 's:Sab:p:c:hr' -- "$@")
if [ $? -ne 0 ] ; then
	echo "Invalid arguments"
	exit 1
fi

eval set -- "$opt"
unset opt

while true; do
  case "$1" in
    '-s')
      shift
      echo "SDK Cache dir: $1"
      SDK_CACHE="$1"
      ;;
    '-S')
      echo "Build SDK Only"
      SDK_ONLY=1
      ;;
    '-a')
      echo "Build firmware images for all the platforms"
      PLATFORMS=""
      ;;
    '-b')
      shift
      echo "Directory to bind to container: $1"
      BIND="$1"
      ;;
    '-p')
      shift
      echo "Build firmware images for the platforms: $1"
      PLATFORMS="$1"
      ;;
    '-c')
      shift
      echo "Build in container: $1"
      CONTAINERS="$1"
      ;;
    '-h')
      echo "Usage: ./ci/build.sh [options]"
      echo "-h          Print this help and exit successfully."
      echo "-a          Build firmware images for all the platform defconfig's."
      echo "-b DIR      Bind DIR to container."
      echo "-p          List of comma separated platform names to build images for particular platforms."
      echo "-s DIR      SDK cache dir (must exist)."
      echo "-S          Build SDK only"
      echo "-c          Container to run in"
      echo ""
      echo "Note: set environment variables HTTP_PROXY and HTTPS_PROXY if a proxy is required."
      echo ""
      echo "Example:DOCKER_PREFIX=sudo ./ci/build.sh -a"
      echo -e "\tDOCKER_PREFIX=sudo ./ci/build.sh -p firestone"
      echo -e "\tDOCKER_PREFIX=sudo ./ci/build.sh -p garrison,palmetto,opal"
      exit 1
      ;;
    '-r')
      echo "Build for release"
      release_args="-r"
      ;;
    '--')
      shift
      break
      ;;
    *)
      echo "Internal Error!"
      exit 1
      ;;
  esac
  shift
done


if [ ! -d "$SDK_CACHE" ]; then
    echo "Error: SDK Cache dir doesn't exist: $SDK_CACHE"
    exit 1
fi

function run_docker
{
	if [ -n "$BIND" ]; then
		BINDARG="--mount=type=bind,src=${BIND},dst=${BIND}"
	else
		BINDARG="--mount=type=bind,src=${PWD},dst=${PWD}"
	fi
	$DOCKER_PREFIX docker run --init --cap-add=sys_admin --net=host --rm=true \
	 --user="${USER}" -w "${PWD}" "${BINDARG}" \
         -t $1 $2
}


env

for distro in $CONTAINERS;
do
	base_dockerfile=ci/Dockerfile/$distro.`uname -m`
	if [ ! -f $base_dockerfile ]; then
	  echo "$distro not supported on $(uname -m).";
	  continue
	fi
	if [[ -n "$HTTP_PROXY" ]]; then
		http_proxy=$HTTP_PROXY
		HTTP_PROXY_ENV="ENV http_proxy $HTTP_PROXY"
	fi
	if [[ -n "$HTTPS_PROXY" ]]; then
		https_proxy=$HTTPS_PROXY
		HTTPS_PROXY_ENV="ENV https_proxy $HTTPS_PROXY"
	fi
	if [[ -n "$http_proxy" ]]; then
	  if [[ "$distro" == fedora30 ]]; then
	    PROXY="RUN echo \"proxy=${http_proxy}\" >> /etc/dnf/dnf.conf"
	  fi
	  if [[ "$distro" == ubuntu1804 ]]; then
	    PROXY="RUN echo \"Acquire::http::Proxy \\"\"${http_proxy}/\\"\";\" > /etc/apt/apt.conf.d/000apt-cacher-ng-proxy"
	  fi
        fi
	if [ ! -z ${DL_DIR+x} ]; then
	  DL_DIR_ENV="ENV DL_DIR $DL_DIR"
	fi
	if [ ! -z ${CCACHE_DIR+x} ]; then
	  CCACHE_DIR_ENV="ENV CCACHE_DIR $CCACHE_DIR"
	fi

	Dockerfile=$(head -n1 $base_dockerfile; echo ${PROXY}; tail -n +2 $base_dockerfile; cat << EOF
${PROXY}
RUN useradd -d ${HOME} -m -u ${UID} ${USER}
ENV HOME ${HOME}
${HTTP_PROXY_ENV}
${HTTPS_PROXY_ENV}
${DL_DIR_ENV}
${CCACHE_DIR_ENV}
EOF
		  )
	$DOCKER_PREFIX docker build --network=host -t openpower/op-build-$distro - <<< "${Dockerfile}"

	if [ -n "$PLATFORMS" ]; then
	    platform_args="-p $PLATFORMS"
	else
	    platform_args=""
	fi

	if [ $SDK_ONLY -ne 0 ]; then
	    sdk_args="-S"
	else
	    sdk_args=""
	fi

	run_docker openpower/op-build-$distro "./ci/build-all-defconfigs.sh -o `pwd`/output-$distro ${platform_args} ${release_args} ${sdk_args} -s $SDK_CACHE"

	if [ $? -ne 0 ]; then
		exit $?;
	fi
done;

