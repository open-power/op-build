################################################################################
#
# hostboot_binaries
#
################################################################################

HOSTBOOT_BINARIES_VERSION = da5ca565422d157e7225d3f20c7ff06f63610f49
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
