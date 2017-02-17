################################################################################
#
# hostboot for POWER8
#
################################################################################
HOSTBOOT_P8_VERSION ?= d3025f5d7ddd0723946bb54fcb471d2bf1fd2da4

HOSTBOOT_P8_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_P8_VERSION))

HOSTBOOT_P8_LICENSE = Apache-2.0
HOSTBOOT_P8_LICENSE_FILES = LICENSE
HOSTBOOT_P8_DEPENDENCIES = host-binutils

HOSTBOOT_P8_INSTALL_IMAGES = YES
HOSTBOOT_P8_INSTALL_TARGET = NO

HOSTBOOT_P8_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_P8_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_P8_VERSION=`cat $(HOSTBOOT_P8_VERSION_FILE)` 

HOSTBOOT_P8_POST_PATCH_HOOKS += HOSTBOOT_P8_APPLY_PATCHES

define HOSTBOOT_P8_BUILD_CMDS
        $(HOSTBOOT_P8_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_P8_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
