################################################################################
#
# capp-ucode.mk
#
################################################################################
CAPP_UCODE_VERSION ?= 9c73e9f51d240847fbd150815a3b9c548aae0cb8
CAPP_UCODE_SITE ?= $(call github,open-power,capp-ucode,$(CAPP_UCODE_VERSION))
CAPP_UCODE_LICENSE = Apache-2.0
CAPP_UCODE_LICENSE_FILES = NOTICES

CAPP_UCODE_INSTALL_IMAGES = YES

define CAPP_UCODE_BUILD_CMDS
	cd $(@D) && ./build.sh
endef

define CAPP_UCODE_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/cappucode.bin $(BINARIES_DIR)
endef

$(eval $(generic-package))
