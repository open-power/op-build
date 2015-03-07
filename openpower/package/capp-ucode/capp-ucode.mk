################################################################################
#
# capp-ucode.mk
#
################################################################################
CAPP_UCODE_VERSION ?= d4b26834dd674b83971d00a8c0952fa5830c8f6a
CAPP_UCODE_SITE ?= $(call github,open-power,capp-ucode,$(CAPP_UCODE_VERSION))
PETITBOOT_LICENSE = Apache-2.0

CAPP_UCODE_INSTALL_IMAGES = YES

define CAPP_UCODE_BUILD_CMDS
	cd $(@D) && ./build.sh
endef

define CAPP_UCODE_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/cappucode.bin $(BINARIES_DIR)
endef

$(eval $(generic-package))
