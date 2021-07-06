################################################################################
#
# ima-catalog.mk
#
################################################################################
IMA_CATALOG_VERSION ?= ab27aaa912cf436c03e0f0dcd1c6135133e9ed7b
IMA_CATALOG_SITE ?= $(call github,open-power,ima-catalog,$(IMA_CATALOG_VERSION))
IMA_CATALOG_LICENSE = Apache-2.0
IMA_CATALOG_DEPENDENCIES = host-dtc host-xz

ifeq ($(BR2_PACKAGE_OPENPOWER_PNOR_P10),y)
IMA_CATALOG_FILENAME=$(BR2_IMA_CATALOG_P10_FILENAME)
else
IMA_CATALOG_FILENAME=$(BR2_IMA_CATALOG_FILENAME)
endif

IMA_CATALOG_INSTALL_IMAGES = YES
IMA_CATALOG_INSTALL_TARGET = NO

define IMA_CATALOG_BUILD_CMDS
       cd $(@D) && ./build.sh $(HOST_DIR)/usr/bin/ $(BR2_IMA_CATALOG_DTS)
endef

define IMA_CATALOG_INSTALL_IMAGES_CMDS
       $(INSTALL) $(@D)/$(IMA_CATALOG_FILENAME) $(BINARIES_DIR)
endef

$(eval $(generic-package))
