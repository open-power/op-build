################################################################################
#
# SBE
#
################################################################################

SBE_VERSION ?= c9fea2e9662bdef548ea4742106b721386240ffe
SBE_SITE ?= $(call github,open-power,sbe,$(SBE_VERSION))

SBE_LICENSE = Apache-2.0
SBE_DEPENDENCIES = host-ppe42-gcc

SBE_INSTALL_IMAGES = YES
SBE_INSTALL_TARGET = NO


define SBE_APPLY_PATCHES
       if [ "$(BR2_OPENPOWER_POWER9)" == "y" ]; then \
           $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/package/sbe \*.patch; \
           if [ -d $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/sbe ]; then \
               $(APPLY_PATCHES) $(@D) $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches/sbe \*.patch; \
           fi; \
       fi;
endef

SBE_POST_PATCH_HOOKS += SBE_APPLY_PATCHES

define SBE_BUILD_CMDS
		bash -c 'cd $(@D)  && make LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib CROSS_COMPILER_PATH=$(PPE42_GCC_BIN)'
endef

define SBE_INSTALL_IMAGES_CMDS
		$(INSTALL) -D $(@D)/images/p9_ipl_build  $(HOST_DIR)/usr/bin/
		python $(@D)/src/build/sbeOpDistribute.py --sbe_binary_dir=$(STAGING_DIR)/sbe_binaries --img_dir=$(@D)/images
		cp $(@D)/src/build/sbeOpDistribute.py $(STAGING_DIR)/sbe_binaries/
endef

$(eval $(generic-package))
