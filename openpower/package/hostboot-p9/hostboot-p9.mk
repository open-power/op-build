################################################################################
#
# hostboot for POWER9
#
################################################################################
HOSTBOOT_P9_VERSION ?= 441fb19059b39a3d440f6db17278fb9567b80e5f
HOSTBOOT_P9_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_P9_VERSION))

HOSTBOOT_P9_LICENSE = Apache-2.0
HOSTBOOT_P9_LICENSE_FILES = LICENSE
HOSTBOOT_P9_DEPENDENCIES = host-binutils
HOSTBOOT_P9_PROVIDES = hostboot

HOSTBOOT_P9_INSTALL_IMAGES = YES
HOSTBOOT_P9_INSTALL_TARGET = NO

HOSTBOOT_P9_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_P9_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_P9_VERSION=`cat $(HOSTBOOT_P9_VERSION_FILE)` 

define HOSTBOOT_P9_BUILD_CMDS
        $(HOSTBOOT_P9_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_P9_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
