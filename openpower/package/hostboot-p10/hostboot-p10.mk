################################################################################
#
# Hostboot for POWER10
#
################################################################################

HOSTBOOT_P10_VERSION = $(call qstrip,$(BR2_HOSTBOOT_P10_VERSION))
HOSTBOOT_P10_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_P10_VERSION))

HOSTBOOT_P10_LICENSE = Apache-2.0
HOSTBOOT_P10_LICENSE_FILES = LICENSE
HOSTBOOT_P10_DEPENDENCIES = host-binutils fsp-trace

HOSTBOOT_P10_INSTALL_IMAGES = YES
HOSTBOOT_P10_INSTALL_TARGET = NO

HOSTBOOT_P10_ENV_VARS=$(TARGET_MAKE_ENV) PERL_USE_UNSAFE_INC=1 \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_P10_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX="$(CCACHE) $(TARGET_CROSS)" HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_VERSION=`cat $(HOSTBOOT_P10_VERSION_FILE)`

FSP_TRACE_IMAGES_DIR = $(STAGING_DIR)/fsp-trace/

# If BR2_PACKAGE_IBM_FW_PROPRIETARY_P10 is defined then
#  * Include repo ibm-fw-proprietary-p10 as a dependency (HOSTBOOT_P10_DEPENDENCIES)
#    to get access to any needed IBM proprietary files.
#  * Create a variable (IBM_FW_PROPRIETARY_P10_BUILD_DIR) to point to the location
#    of the ibm-fw-proprietary-p10 repo for easy access to any files needed.
# Note that if libecc_static.a exists in the $(HOSTBOOT_PRECOMPILED_LIBRARIES)
# directory then we don't require access to the ibm-fw-proprietary repository.
ifeq ($(BR2_PACKAGE_IBM_FW_PROPRIETARY_P10),y)
ifeq ($(wildcard $(HOSTBOOT_PRECOMPILED_LIBRARIES)/libecc_static.a),)
    $(info Using ibm-fw-proprietary for ECC implementation)
    HOSTBOOT_P10_DEPENDENCIES += ibm-fw-proprietary-p10
    IBM_FW_PROPRIETARY_P10_BUILD_DIR = $(BUILD_DIR)/ibm-fw-proprietary-p10-$(IBM_FW_PROPRIETARY_P10_VERSION)
else
    $(info Using $(HOSTBOOT_PRECOMPILED_LIBRARIES)/libecc_static.a for ECC implementation)
endif
endif

# TODO: WORKAROUND: Currently the git clone causes a bad symlink
# to be created for src/include/usr/tracinterface.H; so delete it and rebuild it
# manually
# Copy the VPD ECC algorithm files from the repo ibm-fw-proprietary-p10 to hostboot's
# 'src/user/vpd' directory if environment variable 'IBM_FW_PROPRIETARY_P10_BUILD_DIR'
# is defined.  Whether the VPD ECC algorithm files get compiled or not will be determined
# by flag 'COMPILE_VPD_ECC_ALGORITHMS' within file openpower/configs/hostboot/<systemx>.config.
define HOSTBOOT_P10_BUILD_CMDS
        $(HOSTBOOT_P10_ENV_VARS) bash -c 'cd $(@D) \
                                          && if ! cmp --quiet src/include/usr/trace/interface.H src/include/usr/tracinterface.H ; then \
                                                 rm -f src/include/usr/tracinterface.H && cp src/include/usr/trace/interface.H src/include/usr/tracinterface.H ; \
                                             fi \
                                          && if [ -n "$(IBM_FW_PROPRIETARY_P10_BUILD_DIR)" ] ; then \
                                                 cp --no-clobber $(IBM_FW_PROPRIETARY_P10_BUILD_DIR)/vpd/* src/usr/vpd ; \
                                                 mkdir -p src/build/tools/extern/ibm-fw-proprietary/ ; \
                                                 cp --no-clobber -r $(IBM_FW_PROPRIETARY_P10_BUILD_DIR)/* src/build/tools/extern/ibm-fw-proprietary/ ; \
                                                 echo $(IBM_FW_PROPRIETARY_P10_VERSION) >src/build/tools/extern/ibm-fw-proprietary/LIBECC_COMMIT_HASH ; \
                                             fi \
                                          && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_P10_INSTALL_IMAGES_CMDS
        cd $(@D) && $(HOSTBOOT_P10_ENV_VARS) source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
        cd $(@D) && $(HOSTBOOT_P10_ENV_VARS) source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower-sim $(STAGING_DIR)/hostboot_sim_data/
	cp $(FSP_TRACE_IMAGES_DIR)/fsp-trace $(STAGING_DIR)/hostboot_sim_data/
        mkdir -p $(OUTPUT_IMAGES_DIR)/sim/
	tar -zcvf $(OUTPUT_IMAGES_DIR)/sim/hostboot_sim.tar -C $(STAGING_DIR)/hostboot_sim_data/ .
endef

$(eval $(generic-package))
