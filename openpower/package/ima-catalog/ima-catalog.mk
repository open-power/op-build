################################################################################
#
# ima-catalog.mk
#
################################################################################
IMA_CATALOG_VERSION ?= 0e3bbcb56dfc60fd99b862406ecd3e117117d9af
IMA_CATALOG_SITE ?= $(call github,open-power,ima-catalog,$(IMA_CATALOG_VERSION))
IMA_CATALOG_LICENSE = Apache-2.0
IMA_CATALOG_DEPENDENCIES = host-dtc host-xz

IMA_CATALOG_INSTALL_IMAGES = YES
IMA_CATALOG_INSTALL_TARGET = NO

define IMA_CATALOG_BUILD_CMDS
       cd $(@D) && ./build.sh $(HOST_DIR)/usr/bin/ $(BR2_IMA_CATALOG_DTS)
endef

define IMA_CATALOG_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/$(BR2_IMA_CATALOG_FILENAME) $(BINARIES_DIR)
endef

$(eval $(generic-package))
