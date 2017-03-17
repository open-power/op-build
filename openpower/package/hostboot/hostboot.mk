################################################################################
#
# hostboot
#
################################################################################
HOSTBOOT_VERSION_BRANCH_MASTER_P8 ?= a4b7bb77b3c152af89a57f904f323228ad24373d
HOSTBOOT_VERSION_BRANCH_MASTER ?= d5358edf5e5ff7835099e4503e4bcf1518e24024

HOSTBOOT_VERSION ?= $(if $(BR2_OPENPOWER_POWER9),$(HOSTBOOT_VERSION_BRANCH_MASTER),$(HOSTBOOT_VERSION_BRANCH_MASTER_P8))
HOSTBOOT_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_VERSION))

HOSTBOOT_LICENSE = Apache-2.0
HOSTBOOT_LICENSE_FILES = LICENSE
HOSTBOOT_DEPENDENCIES = host-binutils

HOSTBOOT_INSTALL_IMAGES = YES
HOSTBOOT_INSTALL_TARGET = NO

HOSTBOOT_ENV_VARS=$(TARGET_MAKE_ENV) \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_VERSION=`cat $(HOSTBOOT_VERSION_FILE)` 

define HOSTBOOT_APPLY_PATCHES
       if [ "$(BR2_OPENPOWER_POWER9)" == "y" ]; then \
           $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/package/hostboot/p9Patches \*.patch; \
           if [ -d $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/hostboot/p9Patches ]; then \
               $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/hostboot/p9Patches \*.patch; \
           fi; \
       fi; \
       if [ "$(BR2_OPENPOWER_POWER8)" == "y" ]; then \
           $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/package/hostboot/p8Patches \*.patch; \
           if [ -d $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/hostboot/p8Patches ]; then \
               $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/hostboot/p8Patches \*.patch; \
           fi; \
       fi;
endef

HOSTBOOT_POST_PATCH_HOOKS += HOSTBOOT_APPLY_PATCHES

define HOSTBOOT_BUILD_CMDS
        $(HOSTBOOT_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
