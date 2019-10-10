################################################################################
#
# occ for power10
#
################################################################################

OCC_P10_VERSION = $(call qstrip,$(BR2_OCC_P10_VERSION))
# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#OCC_P10_SITE ?= $(call github,open-power,occ,$(OCC_P10_VERSION))
OCC_P10_SITE = https://github.ibm.com/open-power/occ.git
OCC_P10_SITE_METHOD=git

OCC_P10_LICENSE = Apache-2.0

OCC_P10_LICENSE_FILES = LICENSE

OCC_P10_INSTALL_IMAGES = YES
OCC_P10_INSTALL_TARGET = NO

OCC_P10_STAGING_DIR = $(STAGING_DIR)/occ

OCC_P10_IMAGE_BIN_PATH = obj/image.bin

OCC_P10_DEPENDENCIES = host-binutils host-ppe42-gcc
ifeq ($(BR2_OCC_P10_GPU_BIN_BUILD),y)
	OCC_P10_DEPENDENCIES += hostboot-binaries
endif

define OCC_P10_BUILD_CMDS
	if [ "$(BR2_OCC_P10_GPU_BIN_BUILD)" == "y"  ]; then \
	    cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib GPE1_BIN_IMAGE_PATH=$(STAGING_DIR)/hostboot_binaries/ OPOCC_GPU_SUPPORT=1 all; \
	else \
            cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib all; \
	fi;
endef

OCC_P10_BUILD_CMDS ?= $(OCC_BUILD_CMDS_P9)

define OCC_P10_INSTALL_IMAGES_CMDS
       mkdir -p $(STAGING_DIR)/occ
       cp $(@D)/$(OCC_P10_IMAGE_BIN_PATH) $(OCC_P10_STAGING_DIR)/$(BR2_OCC_P10_BIN_FILENAME)
endef

$(eval $(generic-package))
