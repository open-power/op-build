################################################################################
#
# ima-catalog.mk
#
################################################################################
IMA_CATALOG_VERSION ?= af8bd5ffaed1615c072d4fc6fd436e8f56a5792e
#IMA_CATALOG_SITE ?= $(call github,open-power,ima-catalog,$(IMA_CATALOG_VERSION))
IMA_CATALOG_SITE ?= git@github.ibm.com:open-power/ima-catalog.git
IMA_CATALOG_SITE_METHOD ?= git
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
