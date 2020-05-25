################################################################################
#
# HCODE
#
################################################################################

HCODE_VERSION = $(call qstrip,$(BR2_HCODE_VERSION))
HCODE_SITE = $(call github,open-power,hcode,$(HCODE_VERSION))

HCODE_LICENSE = Apache-2.0

HCODE_INSTALL_IMAGES = YES
HCODE_INSTALL_TARGET = NO

HCODE_DEPENDENCIES = host-binutils host-ppe42-toolchain hostboot-binaries

HW_IMAGE_BIN_PATH=output/images/hw_image
HW_IMAGE_BIN=p9n.hw_image.bin
HCODE_IMAGE_BIN = p9n.ref_image.bin

HW_AXONE_IMAGE_BIN=p9a.hw_image.bin
HCODE_AXONE_IMAGE_BIN = p9a.ref_image.bin

CROSS_COMPILER_PATH=$(PPE42_GCC_BIN)
PPE_TOOL_PATH ?= $(CROSS_COMPILER_PATH)
PPE_PREFIX    ?= $(PPE_TOOL_PATH)/bin/powerpc-eabi-

HCODE_ENV_VARS= CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hcode/$(BR2_HCODE_CONFIG_FILE) \
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib OPENPOWER_BUILD=1\
	CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) PPE_TOOL_PATH=$(CROSS_COMPILER_PATH) \
	PPE_PREFIX=$(CROSS_COMPILER_PATH)/bin/powerpc-eabi- \
	RINGFILEPATH=$(STAGING_DIR)/hostboot_binaries __EKB_PREFIX=$(CXXPATH) \
	CONFIG_IONV_FILE_LOCATION=$(STAGING_DIR)/hostboot_binaries/$(BR2_HOSTBOOT_BINARY_IONV_FILENAME) \
	CONFIG_INCLUDE_IONV=$(BR2_HCODE_INCLUDE_IONV)

define HCODE_INSTALL_IMAGES_CMDS
	mkdir -p $(STAGING_DIR)/hcode
	$(INSTALL) $(@D)/$(HW_IMAGE_BIN_PATH)/$(HW_IMAGE_BIN) $(STAGING_DIR)/hcode/$(HCODE_IMAGE_BIN)
        $(INSTALL) $(@D)/$(HW_IMAGE_BIN_PATH)/$(HW_AXONE_IMAGE_BIN) $(STAGING_DIR)/hcode/$(HCODE_AXONE_IMAGE_BIN)
endef

define HCODE_BUILD_CMDS
		$(HCODE_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE) '
endef

$(eval $(generic-package))
