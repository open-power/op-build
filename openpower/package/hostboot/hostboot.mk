################################################################################
#
# hostboot
#
################################################################################

HOSTBOOT_VERSION ?= 6c5f08212c150d69a931fa4fa1354b6a3aac61e8
HOSTBOOT_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_VERSION))

HOSTBOOT_LICENSE = Apache-2.0
HOSTBOOT_DEPENDENCIES = host-binutils

HOSTBOOT_INSTALL_IMAGES = YES
HOSTBOOT_INSTALL_TARGET = NO

HOSTBOOT_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(BR2_EXTERNAL)/configs/hostboot/$(BR2_HOSTBOOT_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR)

define HOSTBOOT_BUILD_CMDS
        $(HOSTBOOT_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_INSTALL_IMAGES_CMDS
        cd $(@D) && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
