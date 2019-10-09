################################################################################
#
# SBE for P10
#
################################################################################

SBE_P10_VERSION = $(call qstrip,$(BR2_SBE_P10_VERSION))
# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#SBE_P10_SITE = $(call github,open-power,sbe,$(SBE_P10_VERSION))
SBE_P10_SITE = git@github.ibm.com:open-power/sbe.git
SBE_P10_SITE_METHOD=git

SBE_P10_LICENSE = Apache-2.0
SBE_P10_DEPENDENCIES = host-ppe42-gcc hcode-p10
# TODO WORKAROUND ... host-ppe42-gc not compiling
# host-ppe42-gcc hcode-p10

SBE_P10_INSTALL_IMAGES = YES
SBE_P10_INSTALL_TARGET = NO

define SBE_P10_BUILD_CMDS
	SBE_COMMIT_ID=$(SBE_P10_VERSION) $(MAKE) -C $(@D) \
		LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib \
		CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) \
		all
endef

define SBE_P10_INSTALL_IMAGES_CMDS
	$(INSTALL) -D $(@D)/images/ipl_image_tool $(HOST_DIR)/usr/bin/
	python $(@D)/src/build/sbeOpDistribute.py  --sbe_binary_dir=$(STAGING_DIR)/sbe_binaries --img_dir=$(@D)/images --sbe_binary_filename $(BR2_HOSTBOOT_BINARY_SBE_FILENAME)
	cp $(@D)/src/build/sbeOpDistribute.py $(STAGING_DIR)/sbe_binaries/
endef

$(eval $(generic-package))
