################################################################################
#
# hostboot for POWER8
#
################################################################################
HOSTBOOT_P8_VERSION ?= 3267aff2bc1fe97fdf3dc5ab1d210b8d6a2e74eb

HOSTBOOT_P8_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_P8_VERSION))

HOSTBOOT_P8_LICENSE = Apache-2.0
HOSTBOOT_P8_LICENSE_FILES = LICENSE

HOSTBOOT_P8_INSTALL_IMAGES = YES
HOSTBOOT_P8_INSTALL_TARGET = NO

ifeq ($(BR2_HOSTBOOT_P8_USE_ALTERNATE_GCC),y)
HOSTBOOT_P8_TARGET_CROSS = $(HOST_DIR)/alternate-toolchain/bin/$(GNU_TARGET_NAME)-
HOSTBOOT_P8_BINUTILS_DIR = $(HOST_ALTERNATE_BINUTILS_DIR)
HOSTBOOT_P8_DEPENDENCIES = host-alternate-binutils host-alternate-gcc
else
HOSTBOOT_P8_TARGET_CROSS = $(TARGET_CROSS)
HOSTBOOT_P8_BINUTILS_DIR = $(HOST_BINUTILS_DIR)
HOSTBOOT_P8_DEPENDENCIES = host-binutils
endif

HOSTBOOT_P8_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_P8_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(HOSTBOOT_P8_TARGET_CROSS) HOST_PREFIX="" \
    HOST_BINUTILS_DIR=$(HOSTBOOT_P8_BINUTILS_DIR) HOSTBOOT_P8_VERSION=`cat $(HOSTBOOT_P8_VERSION_FILE)`

HOSTBOOT_P8_POST_PATCH_HOOKS += HOSTBOOT_P8_APPLY_PATCHES

define HOSTBOOT_P8_BUILD_CMDS
        $(HOSTBOOT_P8_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_P8_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
