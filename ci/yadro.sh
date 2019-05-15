#!/bin/bash

#
# OpenPOWER firmware builder.
# Script is used to build the firmware image and create distribution packages.
# Copyright (c) 2019 YADRO
#

set -eu

# Define root path of op-build to allow the script to work with any cwd
readonly OPBUILD_ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")"
readonly GIT="git --git-dir=${OPBUILD_ROOT}/.git"
# Default paths
readonly DEFAULT_OUTPUT_DIR="${OPBUILD_ROOT}/output"
readonly DEFAULT_DLCACHE_DIR="${OPBUILD_ROOT}/dl"

# Print help.
function print_help {
  cat << EOF
OpenPOWER firmware builder.
Copyright (c) 2019 YADRO.
Usage: ${BASH_SOURCE[0]} [options] -- [op-build arguments]

  -m MACHINE  Set target machine name [default: vesnin].

  -o DIR      Use DIR as an output directory.
              Default: ${DEFAULT_OUTPUT_DIR}

  -d DIR      Use DIR as a downloads cache directory.
              Default: ${DEFAULT_DLCACHE_DIR}

  -c DIR      Enable ccache and use DIR as a cache directory [default: none].
              It's highly recommended to set this option if you plan to rebuild
              the firmware in future. Using ccache significantly speed up
              subsequent build processes.

  -p DIR      Create distribution packages after successful build.
              Two package are created in DIR:
              1. opfw-{version}.tar.gz: contains PNOR image only;
              2. opfw-{version}-debug.tar.gz: contains debug data;

  -v          Print version string and exit.
              Version string of OpenPOWER firmware depends on the state of the
              current source tree and based on a git branch name and tag.
              Development version format:
                {machine}-{branch}-{git describe output}
                for instance: nicole-master-v2.2-rc2-83-g36afc6ab
              Release version format:
                {machine}-v{major}.{minor}[-p{patchlevel}][-unofficial][-dirty]
                for instance: vesnin-v2.3-g0612c4e
                              nicole-v2.4-p17-g27a9ef6-unofficial

  -h          Print this help and exit.
EOF
}

# Print version info string for current branch.
# param 1: machine name (vesnin, nicole, ...)
function version_string {
  local machine="$1"
  local branch="$(${GIT} rev-parse --abbrev-ref HEAD)"
  if [[ ${branch} != */* ]] || [[ ${branch%%/*} != release ]]; then
    # Development build
    local version="${machine}-${branch##*/}-$(${GIT} describe --always --dirty)"
  else
    # Release build
    if [[ ! ${branch} =~ release/${machine}/v[0-9]+ ]]; then
      echo "Invalid branch name: ${branch}" >&2
      exit 1
    fi
    local tag="$(${GIT} describe --abbrev=0)"
    if [[ ${tag} =~ ${machine}-v[0-9]+\.[0-9]+ ]]; then
      local ver_num="${tag##*-}"
      local patchlvl="$(${GIT} rev-list --count ${tag}..${branch})"
    else
      # Tag hasn't been set yet, use branch name as major version
      local ver_num="${branch##*/}.0"
      local patchlvl="$(${GIT} rev-list --count master..${branch})"
    fi
    # Construct version string
    local version="${machine}-${ver_num}"
    if [[ ${patchlvl} -ne 0 ]]; then
      version+="-p${patchlvl}"
    fi
    version+="-g$(${GIT} rev-parse --short=7 HEAD)"
    if [[ "${ver_num}" == *.0 ]] || [[ ${patchlvl} -ne 0 ]]; then
      version+="-unofficial"
    fi
    if ${GIT} describe --dirty | grep -q dirty; then
      version+="-dirty"
    fi
  fi
  echo "${version}"
}

# Build OpenPOWER firmware image.
# param 1: machine name (vesnin, nicole, ...)
# param 2: path to the build output directory
# param 3: path to the downloads cache directory
# param 4: path to the ccache directory
# param 5: op-build make arguments [optional]
function build_image {
  local machine="$1"
  local output="$2"
  local dlcache="$3"
  local ccache="$4"
  shift 4
  local optargs="$*"
  local version="$(version_string ${machine})"

  # Get buildroot as submodule
  if [[ ! -f ${OPBUILD_ROOT}/buildroot/Makefile ]]; then
    ${GIT} submodule init
    ${GIT} submodule update
  fi

  # Command to start the build process
  local cmd="make --directory=${OPBUILD_ROOT}/buildroot O=${output}"

  # Setup version string, op-build system automatically adds machine name as a
  # platform, so we have to remove it from version string to avoid duplicates
  cmd+=" OPBUILD_VERSION=${version#${machine}-}"

  # Set Hostboot image id using the firmware version instead of hostboot one
  cmd+=" HOSTBOOT_IMAGEID=${version}"

  # Set OpenPOWER build configuration directory
  cmd+=" BR2_EXTERNAL=${OPBUILD_ROOT}/openpower"

  # Set downloads cache directory
  mkdir -p "${dlcache}"
  cmd+=" BR2_DL_DIR=${dlcache}"

  # Set ccache if applicable
  if [[ -n "${ccache}" ]]; then
    mkdir -p "${ccache}"
    cmd+=" BR2_CCACHE=y BR2_CCACHE_DIR=${ccache}"
  fi

  echo "Build parameters (${machine}): ${cmd}"

  # Set default build configuration if it wasn't set earlier
  if [[ ! -f ${output}/.config ]]; then
    ${cmd} ${machine}_defconfig
  fi
  # Build the image
  ${cmd} ${optargs}
}

# Create distribution and debug packages.
# param 1: machine name (vesnin, nicole, ...)
# param 2: path to the build output directory
# param 3: path to the package output directory
function create_packages {
  local machine="$1"
  local output="$2"
  local pkgdir="$3"
  local version="$(version_string ${machine})"

  # Create distribution package
  echo "Create distribution package..."
  local pnor_img="${output}/images/${machine}.pnor"
  chmod a-x "${pnor_img}"
  tar chzf "${pkgdir}/opfw-${version}.tar.gz" -C "$(dirname "${pnor_img}")" "$(basename "${pnor_img}")"

  # Create debug package
  local dbg_dir="${output}/fw_debug"
  local sysroot="${output}/host/powerpc64le-buildroot-linux-gnu/sysroot"
  local hbi_dir="${sysroot}/hostboot_build_images"

  echo "Prepare debug directory..."
  rsync --archive --delete "${hbi_dir}/" "${dbg_dir}/"

  echo "Create MRW report..."
  local mrw_dir="${sysroot}/openpower_mrw_scratch"
  perl -I "${hbi_dir}" "${hbi_dir}/processMrw.pl" -x "${mrw_dir}/${machine}.xml" -r
  mv "${mrw_dir}/${machine}.rpt" "${dbg_dir}"

  echo "Add OCC strings file..."
  local occ_strings="$(ls ${output}/build/occ-*/obj/occStringFile 2>/dev/null || true)"
  if [[ -z "${occ_strings}" ]]; then
    occ_strings="$(ls ${output}/build/occ-*/src/occStringFile 2>/dev/null || true)"
    if [[ -z "${occ_strings}" ]]; then
      echo "OCC strings file not found" >&2
      return 1
    fi
  fi

  cp -fu "${occ_strings}" "${dbg_dir}"
  echo "Add skiboot map file..."
  cp -fu "$(ls ${output}/build/skiboot-*/skiboot.map)" "${dbg_dir}"

  echo "Create debug package..."
  mkdir -p "${pkgdir}"
  tar czf "${pkgdir}/opfw-${version}-debug.tar.gz" -C "$(dirname "${dbg_dir}")" "$(basename "${dbg_dir}")"
}

# Main - script's entry point.
function main {
  local machine="vesnin"
  local output="${DEFAULT_OUTPUT_DIR}"
  local dlcache="${DEFAULT_DLCACHE_DIR}"
  local ccache=""
  local pkgdir=""
  local optargs=""

  local print_version=""

  local opt
  while getopts "m:o:d:c:p:vh" opt; do
    case "${opt}" in
      m) machine="${OPTARG}";;
      o) output="${OPTARG}";;
      d) dlcache="${OPTARG}";;
      c) ccache="${OPTARG}";;
      p) pkgdir="${OPTARG}";;
      v) print_version=y;;
      h) print_help; exit 0;;
      *) exit 1;;
    esac
  done
  shift $((OPTIND - 1))
  optargs="$*"

  # Special actions - print version info only
  if [[ -n "${print_version}" ]]; then
    version_string ${machine}
    exit 0
  fi

  time build_image "${machine}" "${output}" "${dlcache}" "${ccache}" ${optargs}
  if [[ -n "${pkgdir}" ]]; then
    create_packages "${machine}" "${output}" "${pkgdir}"
  fi
}

main $*
