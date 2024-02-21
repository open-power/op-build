################################################################################
#
# SBE for P10
#
################################################################################

SBE_P10_VERSION = $(call qstrip,$(BR2_SBE_P10_VERSION))
SBE_P10_SITE ?= $(call github,open-power,sbe,$(SBE_P10_VERSION))

SBE_P10_LICENSE = Apache-2.0
SBE_P10_DEPENDENCIES = host-ppe42-gcc hcode-p10
# TODO WORKAROUND ... host-ppe42-gc not compiling
# host-ppe42-gcc hcode-p10

SBE_P10_INSTALL_IMAGES = YES
SBE_P10_INSTALL_TARGET = NO

ifeq ($(BR2_PACKAGE_OPENPOWER_PNOR_P10),y)
BINARY_SBE_FILENAME=$(BR2_HOSTBOOT_P10_BINARY_SBE_FILENAME)
else
BINARY_SBE_FILENAME=$(BR2_HOSTBOOT_BINARY_SBE_FILENAME)
endif

define SBE_P10_BUILD_CMDS
	SBE_COMMIT_ID=$(SBE_P10_VERSION) $(MAKE) -C $(@D) \
		LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib \
		CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) \
		all
endef

define SBE_P10_INSTALL_IMAGES_CMDS
	$(INSTALL) -D $(@D)/images/ipl_image_tool $(HOST_DIR)/usr/bin/
	BR2_OPENPOWER_SIGNED_SECURITY_VERSION=${BR2_OPENPOWER_SIGNED_SECURITY_VERSION} \
		python2 $(@D)/src/build/sbeOpDistribute.py --sbe_binary_dir=$(STAGING_DIR)/sbe_binaries --img_dir=$(@D)/images --sbe_binary_filename $(BINARY_SBE_FILENAME)
	cp $(@D)/src/build/sbeOpDistribute.py $(STAGING_DIR)/sbe_binaries/
	cp $(@D)/src/build/sbeOpToolsRegister.py $(STAGING_DIR)/sbe_binaries/
endef

$(eval $(generic-package))
