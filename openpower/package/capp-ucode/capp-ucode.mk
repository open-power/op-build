################################################################################
#
# capp-ucode.mk
#
################################################################################
CAPP_UCODE_VERSION ?= 105cb8f69edb7e76c4d153bf2e5c9718811a3114
CAPP_UCODE_SITE ?= $(call github,open-power,capp-ucode,$(CAPP_UCODE_VERSION))
CAPP_UCODE_LICENSE = Apache-2.0

CAPP_UCODE_INSTALL_IMAGES = YES

define CAPP_UCODE_BUILD_CMDS
	cd $(@D) && ./build.sh
endef

define CAPP_UCODE_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/cappucode.bin $(BINARIES_DIR)
endef

$(eval $(generic-package))
