################################################################################
#
# HCODE for P10
#
################################################################################

HCODE_P10_VERSION = $(call qstrip,$(BR2_HCODE_P10_VERSION))
#HCODE_P10_SITE ?= $(call github,open-power,hcode,$(HCODE_P10_VERSION))
# TODO: Need to comment out above line and enable next two lines
# once buildable P10 HCODE is available in GHE
HCODE_P10_SITE ?= git@github.ibm.com:open-power/hcode.git
HCODE_P10_SITE_METHOD ?= git
HCODE_P10_LICENSE = Apache-2.0

HCODE_P10_INSTALL_IMAGES = YES
HCODE_P10_INSTALL_TARGET = NO

HCODE_P10_DEPENDENCIES = host-binutils host-ppe42-gcc hostboot-binaries

HW_IMAGE_BIN_PATH = output/images/hw_image
HW_IMAGE_BIN_NAME = p10.hw_image.bin
HCODE_IMAGE_BIN_NAME = p10.ref_image.bin

CROSS_COMPILER_PATH=$(PPE42_GCC_BIN)
PPE_TOOL_PATH ?= $(CROSS_COMPILER_PATH)
PPE_PREFIX    ?= $(PPE_TOOL_PATH)/bin/powerpc-eabi-

###################################
# P10 Compilation

ifeq ($(BR2_PACKAGE_OPENPOWER_PNOR_P10),y)
BINARY_IONV_FILENAME=$(BR2_HOSTBOOT_P10_BINARY_IONV_FILENAME)
else
BINARY_IONV_FILENAME=$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)
endif

HCODE_P10_ENV_VARS= CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hcode/$(BR2_HCODE_CONFIG_FILE) \
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib \
	CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) PPE_TOOL_PATH=$(CROSS_COMPILER_PATH) \
	PPE_PREFIX=$(CROSS_COMPILER_PATH)/bin/powerpc-eabi- \
        SELF_REST_PREFIX=$(CROSS_COMPILER_PATH)/bin/powerpc-eabi- \
	RINGFILEPATH=$(STAGING_DIR)/hostboot_binaries __EKB_PREFIX=$(CXXPATH) \
	CONFIG_IONV_FILE_LOCATION=$(STAGING_DIR)/hostboot_binaries/$(BINARY_IONV_FILENAME) \
	CONFIG_INCLUDE_IONV=$(BR2_HCODE_INCLUDE_IONV) OPENPOWER_BUILD=1

define HCODE_P10_INSTALL_IMAGES_CMDS
	mkdir -p $(STAGING_DIR)/hcode
	$(INSTALL) $(@D)/$(HW_IMAGE_BIN_PATH)/$(HW_IMAGE_BIN_NAME) $(STAGING_DIR)/hcode/$(HCODE_IMAGE_BIN_NAME)
endef

define HCODE_P10_BUILD_CMDS
	$(HCODE_P10_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE) -j 2 '
endef

$(eval $(generic-package))
