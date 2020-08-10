################################################################################
#
# ocmb-explorer-fw
#
################################################################################


OCMB_EXPLORER_FW_VERSION ?= $(call qstrip,$(BR2_OCMB_EXPLORER_FW_VERSION))
OCMB_EXPLORER_FW_SOURCE ?= $(call qstrip,$(BR2_OCMB_EXPLORER_FW_SOURCE))
OCMB_EXPLORER_FW_SITE ?= $(call qstrip,$(BR2_OCMB_EXPLORER_FW_SITE))

OCMB_EXPLORER_FW_LICENSE = Apache-2.0
OCMB_EXPLORER_FW_LICENSE_FILES = LICENSE.pdf

OCMB_EXPLORER_FW_INSTALL_IMAGES = YES
OCMB_EXPLORER_FW_INSTALL_TARGET = NO

# Commands to extract and install the Open Capi Memory Buffer Firmware (OCMBFW)
define OCMB_EXPLORER_FW_INSTALL_IMAGES_CMDS
      $(INSTALL) -D $(@D)/$(call qstrip,$(BR2_OCMBFW_FILENAME)) $(BINARIES_DIR)/
endef

define OCMB_EXPLORER_FW_EXTRACT_CMDS
      $(UNZIP) -d $(@D) $(OCMB_EXPLORER_FW_DL_DIR)/$(OCMB_EXPLORER_FW_SOURCE)
      mv $(@D)/*LICENSE*.pdf $(@D)/LICENSE.pdf
endef

$(eval $(generic-package))
