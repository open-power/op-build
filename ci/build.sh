#!/bin/bash

CONTAINERS="ubuntu1604 fedora27"


SDK_ONLY=0

while getopts ":ab:hp:c:rs:S" opt; do
  case $opt in
    s)
      echo "SDK Cache dir"
      SDK_CACHE="$OPTARG"
      ;;
    S)
      echo "Build SDK Only"
      SDK_ONLY=1
      ;;
    a)
      echo "Build firmware images for all the platforms"
      PLATFORMS=""
      ;;
    b)
      echo "Directory to bind to container: $OPTARG"
      BIND="$OPTARG"
      ;;
    p)
      echo "Build firmware images for the platforms: $OPTARG"
      PLATFORMS=$OPTARG
      ;;
    c)
      echo "Build in container: $OPTARG"
      CONTAINERS=$OPTARG
      ;;
    h)
      echo "Usage: ./ci/build.sh [options] [--]"
      echo "-h          Print this help and exit successfully."
      echo "-a          Build firmware images for all the platform defconfig's."
      echo "-b DIR      Bind DIR to container."
      echo "-p          List of comma separated platform names to build images for particular platforms."
      echo "-s DIR      SDK cache dir."
      echo "-S          Build SDK only"
      echo "-c          Container to run in"
      echo "Example:DOCKER_PREFIX=sudo ./ci/build.sh -a"
      echo -e "\tDOCKER_PREFIX=sudo ./ci/build.sh -p firestone"
      echo -e "\tDOCKER_PREFIX=sudo ./ci/build.sh -p garrison,palmetto,openpower_p9_mambo"
      exit 1
      ;;
    r)
      echo "Build for release"
      release_args="-r"
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
	if [ -n "$BIND" ]; then
		BINDARG="--mount=type=bind,src=${BIND},dst=${BIND}"
	else
		BINDARG="--mount=type=bind,src=${PWD},dst=${PWD}"
	fi
	$DOCKER_PREFIX docker run --cap-add=sys_admin --net=host --rm=true \
	 --user="${USER}" -w "${PWD}" "${BINDARG}" \
         -t $1 $2
}

function toolchain_hash
{
    echo -n 'toolchain-'$((git submodule ; cd openpower/configs/; cat `ls -1 |grep '_defconfig$'|sort`)|sha1sum |sed -e 's/ .*//')
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
	  if [[ "$distro" == fedora27 ]]; then
	    PROXY="RUN echo \"proxy=${http_proxy}\" >> /etc/dnf/dnf.conf"
	  fi
	  if [[ "$distro" == ubuntu1604 ]]; then
	    PROXY="RUN echo \"Acquire::http::Proxy \\"\"${http_proxy}/\\"\";\" > /etc/apt/apt.conf.d/000apt-cacher-ng-proxy"
	  fi
        fi
	if [[ -n "DL_DIR" ]]; then
	  DL_DIR_ENV="ENV DL_DIR $DL_DIR"
	fi
	if [[ -n "CCACHE_DIR" ]]; then
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
	if [ -d "$SDK_CACHE" ]; then
	    SDK_DIR=$SDK_CACHE/$(toolchain_hash)-$distro
	    if [ ! -d "$SDK_DIR" ]; then
		chmod +x ci/build-sdk.sh
		run_docker openpower/op-build-$distro "./ci/build-sdk.sh $distro witherspoon_defconfig"
		mv output-$distro-witherspoon_defconfig $SDK_DIR
		$SDK_DIR/host/relocate-sdk.sh
	    fi
	    sdk_args="-s $SDK_DIR/host"
	else
	    sdk_args=""
	fi

	if [ $SDK_ONLY == 0 ]; then
	    run_docker openpower/op-build-$distro "./ci/build-all-defconfigs.sh -o `pwd`/output-$distro -p $PLATFORMS ${release_args} ${sdk_args}"
	fi

	if [ $? != 0 ]; then
		exit $?;
	fi
done;

