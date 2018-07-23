################################################################################
#
# SBE VALIDATION
#
################################################################################

SBE_VALIDATION_SITE_METHOD = git
SBE_VALIDATION_SITE = git@github.ibm.com:openbmc/sbe-validation.git
SBE_VALIDATION_VERSION = $(call qstrip,$(BR2_SBE_VALIDATION_VERSION))

SBE_VALIDATION_LICENSE = Apache-2.0

SBE_VALIDATION_DEPENDENCIES =

SBE_VALIDATION_INSTALL_IMAGES = YES
SBE_VALIDATION_INSTALL_TARGET = NO

define SBE_VALIDATION_EXTRACT_CMDS
	rm -rf $(SBE_VALIDATION_SITE) $(@D)/git
	git clone $(SBE_VALIDATION_SITE) $(@D)/git
	cd $(@D)/git && git checkout $(SBE_VALIDATION_VERSION)
endef

define SBE_VALIDATION_BUILD_CMDS
	cd $(@D)/git; ./bootstrap.sh; ./configure; make clean && make
endef

define SBE_VALIDATION_INSTALL_IMAGES_CMDS
	mkdir -p $(STAGING_DIR)/sbe_binaries
	$(INSTALL) -D $(@D)/git/src/imageValidation $(STAGING_DIR)/sbe_binaries/
endef

$(eval $(generic-package))
