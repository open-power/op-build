################################################################################
#
# ima-catalog.mk
#
################################################################################
IMA_CATALOG_VERSION ?= 0dd89526d8e7f8d82d0b4740366221bf04948084
IMA_CATALOG_SITE ?= $(call github,open-power,ima-catalog,$(IMA_CATALOG_VERSION))
IMA_CATALOG_LICENSE = Apache-2.0
IMA_CATALOG_DEPENDENCIES = host-dtc host-xz

IMA_CATALOG_INSTALL_IMAGES = YES

define IMA_CATALOG_BUILD_CMDS
	cd $(@D) && ./build.sh $(HOST_DIR)/usr/bin/ $(BR2_IMA_CATALOG_DTS_FILENAME)
endef

define IMA_CATALOG_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/$(BR2_IMA_CATALOG_BIN_FILENAME) $(BINARIES_DIR)
endef

$(eval $(generic-package))
