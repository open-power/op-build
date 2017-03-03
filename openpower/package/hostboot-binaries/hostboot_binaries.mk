################################################################################
#
# hostboot_binaries
#
################################################################################

HOSTBOOT_BINARIES_VERSION ?= 4b440901a7331507f56ca19a96c9203f7e570309
HOSTBOOT_BINARIES_SITE ?= $(call github,open-power,hostboot-binaries,$(HOSTBOOT_BINARIES_VERSION))
HOSTBOOT_BINARIES_LICENSE = Apache-2.0
HOSTBOOT_BINARIES_LICENSE_FILES = LICENSE

HOSTBOOT_BINARIES_INSTALL_IMAGES = YES
HOSTBOOT_BINARIES_INSTALL_TARGET = NO

define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/cvpd.bin  $(STAGING_DIR)/hostboot_binaries/cvpd.bin
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_WINK_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBE_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
endef

$(eval $(generic-package))
