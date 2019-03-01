#!/bin/bash

#
# OpenPOWER firmware builder for VESNIN server.
# Copyright (c) 2019 YADRO
#

set -eu

# Constant build properties
readonly VENDOR_NAME="yadro"
readonly PLATFORM_NAME="vesnin"
readonly CONFIG_NAME="vesnin_defconfig"

# Print help.
function print_help {
  cat << EOF
OpenPOWER firmware builder for VESNIN server.
Copyright (c) 2019 YADRO.
Usage: ${BASH_SOURCE[0]} [OPTION]
  -d DIR   Override path used for downloads cache.
           By defult, the cache directory is placed inside the project
           root. If you want to use a common cache directory across different
           builds, this option is what you need.

  -c DIR   If set, specified DIR will be used as the ccache directory,
           it's highly recommended to set this option if you plan to
           rebuild the image. Using ccache significantly speed up the
           build process.

  -p DIR   If set, the distribution packages will be created in
           the specified DIR after a successful build.
           Two package are created:
           1. pnor-*.tar.gz: contains PNOR image only;
           2. pnor-*-debug.tar.gz: contains debug data;

  -v       Print version string for PNOR image and exit,
           version data is constructed for current state of the
           source tree and based on git branch name and tag.

  -h       Print this help and exit
EOF
}

# Print version info string for current branch.
# Format:
# - Development version:
#   {branch name}-{git describe output}
#   for instance: master-v2.2-rc2-83-g36afc6ab
# - Release version:
#   {platform}-v{major}.{minor}[-p{patchlevel}][-unofficial][-dirty]
#   for instance: vesnin-v2.3-g0612c4e
#                 vesnin-v2.3-p17-g0612c4e-unofficial
function print_version {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ ${branch} != */* ]] || [[ ${branch%/*} != release ]]; then
    # Development build
    local version="${branch##*/}-$(git describe --always --dirty)"
  else
    # Release build
    local official=y
    local tag="$(git describe --abbrev=0)"
    if [[ ${tag} == ${PLATFORM_NAME}-* ]]; then
      local version="${tag}"
    else
      # Tag hasn't been set yet, use branch name as major version
      local version="${PLATFORM_NAME}-${branch##*/}.0"
      # Non tagged branch is not an officail build
      official=
    fi
    local patchlvl="$(git rev-list --count master..${branch})"
    if [[ ${patchlvl} -ne 0 ]]; then
      version+="-p${patchlvl}"
      # Any non-0 patchlevel is not a officail build
      official=
    fi
    version+="-g$(git rev-parse --short=7 HEAD)"
    [[ -n "${official}" ]] || version+="-unofficial"
    git describe --dirty | grep -q dirty && version+="-dirty"
  fi
  echo "${version}"
}

# Build PNOR image.
# param 1: path to downloads cache directory
# param 2: path to ccache directory
function build_image {
  local dlcache="$1"
  local ccache="$2"

  # Get buildroot as submodule
  if [[ ! -f ./buildroot/Makefile ]]; then
    git submodule init
    git submodule update
  fi

  source ./op-build-env

  # Setup downloads cache
  if [[ -n "${dlcache}" ]]; then
    export BR2_DL_DIR="${dlcache}"
  fi

  # Setup ccache if it applicable
  if [[ -n "${ccache}" ]]; then
    export BR2_CCACHE=y
    export BR2_CCACHE_DIR="${ccache}"
  fi

  # Setup image's properties
  export OPBUILD_VENDOR="${VENDOR_NAME}"
  export OPBUILD_VERSION="$(print_version)"
  export OPBUILD_PLATFORM="${PLATFORM_NAME}"

  echo "Build environment:"
  env | grep -P 'OPBUILD|BR2' | sort

  # Set build configuration
  op-build ${CONFIG_NAME}
  # Build the image
  op-build
}

# Create distribution and debug packages.
# param 1: path to the package directory
function create_packages {
  local pkgdir="$1"
  local version="$(print_version)"

  # Create distribution package
  echo "Create distribution package..."
  chmod a-x ./output/images/vesnin.pnor
  tar chzf "${pkgdir}/pnor-${version}.tar.gz" -C ./output/images vesnin.pnor

  # Create debug package
  local dbgdir="./output/fw_debug"
  [[ -e ${dbgdir} ]] || ln -sr "./output/staging/hostboot_build_images" "${dbgdir}"
  echo "Create MRW report..."
  (cd "${dbgdir}" && perl ./processMrw.pl -x ../openpower_mrw_scratch/vesnin.xml -r)
  cp ./output/staging/openpower_mrw_scratch/vesnin.rpt "${dbgdir}"
  echo "Add debug files..."
  cp ./output/build/occ-p8-*/src/occStringFile "${dbgdir}"
  cp ./output/build/skiboot-*/skiboot.map "${dbgdir}"
  echo "Create debug package..."
  tar chzf "${pkgdir}/pnor-${version}-debug.tar.gz" -C ./output fw_debug
}

# Main - script's entry point.
function main {
  local dlcache=""
  local pkgdir=""
  local ccache=""

  local opt
  while getopts "d:c:p:vh" opt; do
    case "${opt}" in
      d) dlcache="${OPTARG}";;
      c) ccache="${OPTARG}";;
      p) pkgdir="${OPTARG}";;
      v) print_version; exit 0;;
      h) print_help; exit 0;;
      *) print_help; exit 1;;
    esac
  done

  # Check/change current directory, which must be root of the op-build
  if [[ ! -f ./op-build-env ]]; then
    cd "$(realpath "$(dirname "${BASH_SOURCE[0]}/..")")"
    if [[ ! -f ./op-build-env ]]; then
      echo "Root directory of op-build not found!" >&2
      return 1
    fi
  fi

  # Check directories
  if [[ -n "${dlcache}" ]] && [[ ! -d ${dlcache} ]]; then
    echo "Downloads cache directory ${dlcache} not found!" >&2
    return 1
  fi
  if [[ -n "${ccache}" ]] && [[ ! -d ${ccache} ]]; then
    echo "ccache directory ${ccache} not found!" >&2
    return 1
  fi
  if [[ -n "${pkgdir}" ]] && [[ ! -d ${pkgdir} ]]; then
    echo "Output package directory ${pkgdir} not found!" >&2
    return 1
  fi

  time build_image "${dlcache}" "${ccache}"
  if [[ -n "${pkgdir}" ]]; then
    create_packages "${pkgdir}"
  fi
}

main $*
