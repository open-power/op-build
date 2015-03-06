################################################################################
#
# capp-ucode.mk
#
################################################################################
CAPP_UCODE_VERSION ?= e5167a6f534ea3bdc2faef80dc37ee806a3f2eb1
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
