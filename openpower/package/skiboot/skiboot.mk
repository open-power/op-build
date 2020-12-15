################################################################################
#
# skiboot
#
################################################################################

SKIBOOT_VERSION = $(call qstrip,$(BR2_SKIBOOT_VERSION))

ifeq ($(BR2_SKIBOOT_CUSTOM_GIT),y)
SKIBOOT_SITE = $(call qstrip,$(BR2_SKIBOOT_CUSTOM_REPO_URL))
SKIBOOT_SITE_METHOD = git
else
SKIBOOT_SITE = $(call github,open-power,skiboot,$(SKIBOOT_VERSION))
endif

SKIBOOT_LICENSE = Apache-2.0
SKIBOOT_LICENSE_FILES = LICENCE
SKIBOOT_INSTALL_IMAGES = YES
SKIBOOT_INSTALL_TARGET = NO


ifeq ($(BR2_PACKAGE_SKIBOOT_EMBED_PAYLOAD),y)
SKIBOOT_MAKE_OPTS += KERNEL=$(BINARIES_DIR)/$(LINUX_IMAGE_NAME)
SKIBOOT_DEPENDENCIES += linux
endif

ifeq ($(BR2_SKIBOOT_DEVICETREE),y)
SKIBOOT_DEPENDENCIES += host-dtc
define SKIBOOT_BUILD_DEVICETREE
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/external/devicetree all
endef
define SKIBOOT_INSTALL_DEVICETREE
	$(INSTALL) -D -m 644 $(@D)/external/devicetree/*.dtb $(BINARIES_DIR)
endef
endif

# Pass Configure opts as env to not override Skiboot's
# Additionally, Skiboot expects SKIBOOT_VERSION as env
define SKIBOOT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) \
		SKIBOOT_VERSION=`cat $(SKIBOOT_VERSION_FILE)` \
		$(MAKE) -C $(@D) $(SKIBOOT_MAKE_OPTS) all
	$(SKIBOOT_BUILD_DEVICETREE)
endef

define SKIBOOT_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 755 $(@D)/skiboot.lid $(BINARIES_DIR)
	$(SKIBOOT_INSTALL_DEVICETREE)
endef

$(eval $(generic-package))
