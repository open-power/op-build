################################################################################
#
# occ for POWER9
#
################################################################################

OCC_P9_VERSION ?= dbb4d7e88cf3a4f83d4b67b6ff90cb222503c60c

OCC_P9_SITE ?= $(call github,open-power,occ,$(OCC_P9_VERSION))
OCC_P9_LICENSE = Apache-2.0

OCC_P9_LICENSE_FILES = LICENSE

OCC_P9_INSTALL_IMAGES = YES
OCC_P9_INSTALL_TARGET = NO

OCC_P9_STAGING_DIR = $(STAGING_DIR)/occ

OCC_P9_IMAGE_BIN_PATH = obj/image.bin

OCC_P9_DEPENDENCIES = host-binutils host-ppe42-gcc hostboot-binaries

define OCC_P9_BUILD_CMDS
	if [ "$(BR2_OCC_P9_GPU_BIN_BUILD)" == "y"  ]; then \
	    cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_P9_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib GPE1_BIN_IMAGE_PATH=$(STAGING_DIR)/hostboot_binaries/ OPOCC_P9_GPU_SUPPORT=1 all; \
	else \
            cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_P9_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib all; \
	fi;
endef
OCC_P9_BUILD_CMDS ?= $(OCC_P9_BUILD_CMDS_P9)

define OCC_P9_INSTALL_IMAGES_CMDS
       mkdir -p $(STAGING_DIR)/occ
       cp $(@D)/$(OCC_P9_IMAGE_BIN_PATH) $(OCC_P9_STAGING_DIR)/$(BR2_OCC_P9_BIN_FILENAME)
endef

$(eval $(generic-package))
