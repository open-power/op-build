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

# Creating Install Commands specific to P9
# -- P9 does not need the SBE files ('sbe' package is used in P9)
# -- P9 uses the 'hcode' package to build the BR2_HOSTBOOT_BINARY_WINK_FILENAME

###################################
# P9:
ifeq ($(BR2_OPENPOWER_POWER9),y)

NIMBUS_RING_FILE=p9n.hw.rings.bin
NIMBUS_RING_OVERLAYS_FILE=p9n.hw.overlays.bin

AXONE_RING_FILE=p9a.hw.rings.bin
AXONE_RING_OVERLAYS_FILE=p9a.hw.overlays.bin


define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/cvpd.bin  $(STAGING_DIR)/hostboot_binaries/cvpd.bin
     $(INSTALL) -D $(@D)/gpu_gpe1.bin  $(STAGING_DIR)/hostboot_binaries/gpu_gpe1.bin
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(NIMBUS_RING_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(NIMBUS_RING_OVERLAYS_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(AXONE_RING_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(AXONE_RING_OVERLAYS_FILE)  $(STAGING_DIR)/hostboot_binaries/
endef
endif


$(eval $(generic-package))
