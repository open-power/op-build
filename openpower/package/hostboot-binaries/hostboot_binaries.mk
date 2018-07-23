################################################################################
#
# hostboot_binaries
#
################################################################################


HOSTBOOT_BINARIES_VERSION = $(call qstrip,$(BR2_HOSTBOOT_BINARIES_VERSION))
HOSTBOOT_BINARIES_SITE ?= $(call github,open-power,hostboot-binaries,$(HOSTBOOT_BINARIES_VERSION))

HOSTBOOT_BINARIES_LICENSE = Apache-2.0
HOSTBOOT_BINARIES_LICENSE_FILES = LICENSE

HOSTBOOT_BINARIES_INSTALL_IMAGES = YES
HOSTBOOT_BINARIES_INSTALL_TARGET = NO

NIMBUS_RING_FILE=p9n.hw.rings.bin
NIMBUS_RING_OVERLAYS_FILE=p9n.hw.overlays.bin

#for P9 the hw_ref image is changing to not be padded with ECC.  However
#all the other op-build files use the end name result.  Thus replace ".hdr.bin.ecc"
#with ".bin"
BIN_FILENAME ?= $(if $(BR2_OPENPOWER_POWER9),$(subst hdr.bin.ecc,bin,$(BR2_HOSTBOOT_BINARY_WINK_FILENAME)),$(BR2_HOSTBOOT_BINARY_WINK_FILENAME))

define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/cvpd.bin  $(STAGING_DIR)/hostboot_binaries/cvpd.bin
     $(INSTALL) -D $(@D)/$(BIN_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBE_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/gpu_gpe1.bin  $(STAGING_DIR)/hostboot_binaries/gpu_gpe1.bin
     $(INSTALL) -D $(@D)/$(NIMBUS_RING_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(NIMBUS_RING_OVERLAYS_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
endef

$(eval $(generic-package))
