################################################################################
#
# devicetree
#
################################################################################

# Source is local; package/devicetree/source/*.dts
DEVICETREE_SOURCE = $(call qstrip,$(BR2_DEVICETREE_SOURCE))
DEVICETREE_SITE = $(DEVICETREE_PKGDIR)source
DEVICETREE_SITE_METHOD = local

DEVICETREE_INSTALL_IMAGES = YES
DEVICETREE_INSTALL_TARGET = NO
DEVICETREE_DEPENDENCIES = host-dtc

ifeq ($(BR2_PACKAGE_DEVICETREE),y)
ifeq ($(DEVICETREE_SOURCE),)
$(error No device tree source set. Check your BR2_DEVICETREE_SOURCE setting)
endif
endif

define DEVICETREE_BUILD_CMDS
	$(HOST_DIR)/usr/bin/dtc \
		-I dts $(@D)/$(DEVICETREE_SOURCE) \
		-O dtb -o $(@D)/devicetree.dtb
endef

define DEVICETREE_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/devicetree.dtb $(BINARIES_DIR)
endef

$(eval $(generic-package))
