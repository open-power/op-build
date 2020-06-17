################################################################################
#
# ocmb-explorer-fw
#
################################################################################


OCMB_EXPLORER_FW_VERSION ?= $(call qstrip,$(BR2_OCMB_EXPLORER_FW_VERSION))
OCMB_EXPLORER_FW_SOURCE ?= $(call qstrip,$(BR2_OCMBFW_FILENAME))
OCMB_EXPLORER_FW_SITE ?= $(call qstrip,$(BR2_OCMB_EXPLORER_FW_URL))/releases/download/$(BR2_OCMB_EXPLORER_FW_VERSION)

OCMB_EXPLORER_FW_LICENSE = Apache-2.0
OCMB_EXPLORER_FW_LICENSE_FILES = LICENSE

OCMB_EXPLORER_FW_INSTALL_IMAGES = YES
OCMB_EXPLORER_FW_INSTALL_TARGET = NO

# Commands to extract and install the Open Capi Memory Buffer Firmware (OCMBFW)
define OCMB_EXPLORER_FW_INSTALL_IMAGES_CMDS
      $(INSTALL) -D $(@D)/$(OCMB_EXPLORER_FW_SOURCE) $(BINARIES_DIR)/
endef

define OCMB_EXPLORER_FW_EXTRACT_CMDS
      cp $(DL_DIR)/ocmb-explorer-fw/$(OCMB_EXPLORER_FW_SOURCE) $(@D)/
endef

$(eval $(generic-package))
