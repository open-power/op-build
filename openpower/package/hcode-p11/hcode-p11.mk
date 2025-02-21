################################################################################
#
# HCODE for P11
#
################################################################################

HCODE_P11_VERSION = $(call qstrip,$(BR2_HCODE_P11_VERSION))

# Public
HCODE_P11_SITE ?= $(call github,open-power,hcode,$(HCODE_P11_VERSION))

#Private
#HCODE_P11_SITE ?= git@github.ibm.com:open-power/hcode.git
#HCODE_P11_SITE_METHOD ?= git

HCODE_P11_LICENSE = Apache-2.0
HCODE_P11_INSTALL_IMAGES = YES
HCODE_P11_INSTALL_TARGET = NO

HCODE_P11_DEPENDENCIES = host-binutils host-ppe42-gcc hostboot-binaries

HW_IMAGE_BIN_PATH = output/images/hw_image
HW_IMAGE_BIN_NAME = p10.hw_image.bin
HCODE_IMAGE_BIN_NAME = p10.ref_image.bin
QME20_TREXSTRING_PATH=hcode/qme_p10dd20/
XGPE20_TREXSTRING_PATH=hcode/xgpe_p10dd20/
PGPE20_TREXSTRING_PATH=hcode/pgpe_p10dd20/

CROSS_COMPILER_PATH=$(PPE42_GCC_BIN)
PPE_TOOL_PATH ?= $(CROSS_COMPILER_PATH)
PPE_PREFIX    ?= $(PPE_TOOL_PATH)/bin/powerpc-eabi-

###################################
# P11 Compilation

ifeq ($(BR2_PACKAGE_OPENPOWER_PNOR_P11),y)
BINARY_IONV_FILENAME=$(BR2_HOSTBOOT_P11_BINARY_IONV_FILENAME)
else
BINARY_IONV_FILENAME=$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)
endif

HCODE_P11_ENV_VARS= CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hcode/$(BR2_HCODE_CONFIG_FILE) \
	LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib \
	CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) PPE_TOOL_PATH=$(CROSS_COMPILER_PATH) \
	PPE_PREFIX=$(CROSS_COMPILER_PATH)/bin/powerpc-eabi- \
        SELF_REST_PREFIX=$(CROSS_COMPILER_PATH)/bin/powerpc-eabi- \
	RINGFILEPATH=$(STAGING_DIR)/hostboot_binaries __EKB_PREFIX=$(CXXPATH) \
	CONFIG_IONV_FILE_LOCATION=$(STAGING_DIR)/hostboot_binaries/$(BINARY_IONV_FILENAME) \
	CONFIG_INCLUDE_IONV=$(BR2_HCODE_INCLUDE_IONV) OPENPOWER_BUILD=1


define HCODE_P11_INSTALL_IMAGES_CMDS
	mkdir -p $(STAGING_DIR)/hcode
    mkdir -p $(STAGING_DIR)/$(QME20_TREXSTRING_PATH)
	mkdir -p $(STAGING_DIR)/$(XGPE20_TREXSTRING_PATH)
	mkdir -p $(STAGING_DIR)/$(PGPE20_TREXSTRING_PATH)
	$(INSTALL) $(@D)/output/images/qme_p10dd20/trexStringFile $(STAGING_DIR)/$(QME20_TREXSTRING_PATH)
	$(INSTALL) $(@D)/output/images/xgpe_p10dd20/trexStringFile $(STAGING_DIR)/$(XGPE20_TREXSTRING_PATH)
	$(INSTALL) $(@D)/output/images/pgpe_p10dd20/trexStringFile $(STAGING_DIR)/$(PGPE20_TREXSTRING_PATH)
	$(INSTALL) $(@D)/$(HW_IMAGE_BIN_PATH)/$(HW_IMAGE_BIN_NAME) $(STAGING_DIR)/hcode/$(HCODE_IMAGE_BIN_NAME)
endef

define HCODE_P11_BUILD_CMDS
	$(HCODE_P11_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE) '
endef


$(eval $(generic-package))
