################################################################################
#
# hostboot
#
################################################################################

HOSTBOOT_VERSION ?= 787d61d8918730232ac546e0b679a19723fdd70a
HOSTBOOT_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_VERSION))

HOSTBOOT_LICENSE = Apache-2.0
HOSTBOOT_DEPENDENCIES = host-binutils

HOSTBOOT_INSTALL_IMAGES = YES
HOSTBOOT_INSTALL_TARGET = NO

# The BR2_HOSTBOOT_CONFIG_FILE variable has quotes around it, which throws off the wildcard function
BR2_HOSTBOOT_CONFIG_FILE_NONQUOTED := $(shell echo $(BR2_HOSTBOOT_CONFIG_FILE))

# Setup the Custom and Default Paths to find the config file
CUSTOM_CONFIG_PATH=$(BR2_EXTERNAL)/custom/configs/hostboot/$(BR2_HOSTBOOT_CONFIG_FILE_NONQUOTED)
DEFAULT_CONFIG_PATH=$(BR2_EXTERNAL)/configs/hostboot/$(BR2_HOSTBOOT_CONFIG_FILE_NONQUOTED)

HOSTBOOT_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(or $(wildcard $(CUSTOM_CONFIG_PATH)),$(wildcard $(DEFAULT_CONFIG_PATH))) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_VERSION=`cat $(HOSTBOOT_VERSION_FILE)`

define HOSTBOOT_BUILD_CMDS
        $(HOSTBOOT_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_INSTALL_IMAGES_CMDS
        cd $(@D) && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
