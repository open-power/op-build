################################################################################
#
# hostboot_binaries
#
################################################################################

HOSTBOOT_BINARIES_VERSION = $(call qstrip,$(BR2_HOSTBOOT_BINARIES_VERSION))
# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#HOSTBOOT_BINARIES_SITE ?= $(call github,open-power,hostboot-binaries,$(HOSTBOOT_BINARIES_VERSION))
HOSTBOOT_BINARIES_SITE ?= git@github.ibm.com:open-power/hostboot-binaries.git
HOSTBOOT_BINARIES_SITE_METHOD ?= git

HOSTBOOT_BINARIES_LICENSE = Apache-2.0
HOSTBOOT_BINARIES_LICENSE_FILES = LICENSE

HOSTBOOT_BINARIES_INSTALL_IMAGES = YES
HOSTBOOT_BINARIES_INSTALL_TARGET = NO

# Creating Install Commands specific to P8 and P9
# -- P8 does not need the nimbus and axone ring files
# -- P9 does not need the SBE files ('sbe' package is used in P9)
# -- P9 uses the 'hcode' package to build the BR2_HOSTBOOT_BINARY_WINK_FILENAME

###################################
# P8:
ifeq ($(BR2_OPENPOWER_POWER8),y)
define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/cvpd.bin  $(STAGING_DIR)/hostboot_binaries/cvpd.bin
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_WINK_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBE_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/gpu_gpe1.bin  $(STAGING_DIR)/hostboot_binaries/gpu_gpe1.bin
endef
endif

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

###################################
# P10:
ifeq ($(BR2_OPENPOWER_POWER10),y)

P10_RING_DYNAMIC_FILE=p10.hw.dynamic.bin
P10_RING_OVERLAYS_FILE=p10.hw.overlays.bin
P10_RING_QME_FILE=p10.hw.qme.rings.bin
P10_RING_SBE_FILE=p10.hw.sbe.rings.bin
P10_RING_FA_EC_CL2_FILE=p10.hw.fa_ec_cl2_far.bin
P10_RING_FA_EC_MMA_FILE=p10.hw.fa_ec_mma_far.bin
P10_RING_FA_OVRD_FILE=p10.hw.fa_ring_ovrd.bin
P10_RING_DYNAMIC_FEATURES_FILE=p10.dynamic_features.bin
P10_RING_DYNAMIC_SERVICES_FILE=p10.dynamic_services.bin
P10_RING_HDCT_FILE=p10.hw.hdct.bin

define HOSTBOOT_BINARIES_INSTALL_IMAGES_CMDS
     $(INSTALL) -D $(@D)/gpu_gpe1.bin  $(STAGING_DIR)/hostboot_binaries/gpu_gpe1.bin
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_IONV_FILENAME)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_DYNAMIC_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_OVERLAYS_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_QME_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_SBE_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_FA_EC_CL2_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_FA_EC_MMA_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_FA_OVRD_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_DYNAMIC_FEATURES_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_DYNAMIC_SERVICES_FILE)  $(STAGING_DIR)/hostboot_binaries/
     $(INSTALL) -D $(@D)/$(P10_RING_HDCT_FILE)  $(STAGING_DIR)/hostboot_binaries/
endef
endif

$(eval $(generic-package))
