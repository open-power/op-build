################################################################################
#
# hostboot_binaries
#
################################################################################

HOSTBOOT_BINARIES_VERSION = d4702ceb2b55bc9cba6b80b1088f61d9b65b3c1c
HOSTBOOT_BINARIES_SITE = $(call github,open-power,hostboot-binaries,$(HOSTBOOT_BINARIES_VERSION))
HOSTBOOT_BINARIES_LICENSE = Apache-2.0

HOSTBOOT_BINARIES_INSTALL_IMAGES = YES
HOSTBOOT_BINARIES_INSTALL_TARGET = NO

define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/cvpd.bin  $(STAGING_DIR)/hostboot_binaries/cvpd.bin
     $(INSTALL) -D $(@D)/p8.ref_image.hdr.bin.ecc  $(STAGING_DIR)/hostboot_binaries/p8.ref_image.hdr.bin.ecc
     $(INSTALL) -D $(@D)/palmetto_sbec_pad.img.ecc  $(STAGING_DIR)/hostboot_binaries/palmetto_sbec_pad.img.ecc
     $(INSTALL) -D $(@D)/palmetto_sbe.img.ecc  $(STAGING_DIR)/hostboot_binaries/palmetto_sbe.img.ecc
endef

$(eval $(generic-package))
