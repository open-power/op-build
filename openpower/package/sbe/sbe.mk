################################################################################
#
# SBE
#
################################################################################

SBE_VERSION ?= d770027426ba0c5d6c44fa985e9dfaf28fd6fcce
SBE_SITE ?= $(call github,open-power,sbe,$(SBE_VERSION))

SBE_LICENSE = Apache-2.0
SBE_DEPENDENCIES = host-ppe42-gcc

SBE_INSTALL_IMAGES = YES
SBE_INSTALL_TARGET = NO

define SBE_BUILD_CMDS
	SBE_COMMIT_ID=$(SBE_VERSION) $(MAKE1) -C $(@D) \
		LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib \
		CROSS_COMPILER_PATH=$(PPE42_GCC_BIN) \
		all
endef

define SBE_INSTALL_IMAGES_CMDS
	$(INSTALL) -D $(@D)/images/p9_ipl_build  $(HOST_DIR)/usr/bin/
	python $(@D)/src/build/sbeOpDistribute.py --sbe_binary_dir=$(STAGING_DIR)/sbe_binaries --img_dir=$(@D)/images
	cp $(@D)/src/build/sbeOpDistribute.py $(STAGING_DIR)/sbe_binaries/
endef

$(eval $(generic-package))
