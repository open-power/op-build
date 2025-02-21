################################################################################
#
# occ for power11
#
################################################################################

OCC_P11_VERSION = $(call qstrip,$(BR2_OCC_P11_VERSION))

#Public
OCC_P11_SITE ?= $(call github,open-power,occ,$(OCC_P11_VERSION))

#Private
#OCC_P11_SITE ?= git@github.ibm.com:open-power/occ.git
#OCC_P11_SITE_METHOD ?= git

OCC_P11_LICENSE = Apache-2.0

OCC_P11_LICENSE_FILES = LICENSE

OCC_P11_INSTALL_IMAGES = YES
OCC_P11_INSTALL_TARGET = NO

OCC_P11_STAGING_DIR = $(STAGING_DIR)/occ

OCC_P11_IMAGE_BIN_PATH = obj/image.bin
OCC_P11_STRING_PATH = obj/occStringFile

OCC_P11_DEPENDENCIES = host-binutils host-ppe42-gcc
ifeq ($(BR2_OCC_P11_GPU_BIN_BUILD),y)
	OCC_P11_DEPENDENCIES += hostboot-binaries
endif

define OCC_P11_BUILD_CMDS
	if [ "$(BR2_OCC_P11_GPU_BIN_BUILD)" == "y"  ]; then \
	    cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib GPE1_BIN_IMAGE_PATH=$(STAGING_DIR)/hostboot_binaries/ OPOCC_GPU_SUPPORT=1 all; \
	else \
            cd $(@D)/src && \
            make PPE_TOOL_PATH=$(PPE42_GCC_BIN) OCC_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib all; \
	fi;
endef

OCC_P11_BUILD_CMDS ?= $(OCC_BUILD_CMDS_P9)

define OCC_P11_INSTALL_IMAGES_CMDS
       mkdir -p $(STAGING_DIR)/occ
       cp $(@D)/$(OCC_P11_IMAGE_BIN_PATH) $(OCC_P11_STAGING_DIR)/$(BR2_OCC_P11_BIN_FILENAME)
       cp $(@D)/$(OCC_P11_STRING_PATH)    $(OCC_P11_STAGING_DIR)/occStringFile
endef

$(eval $(generic-package))
