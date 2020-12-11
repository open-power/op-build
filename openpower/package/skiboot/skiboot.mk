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

ifeq ($(BR2_SKIBOOT_DEVICETREE),y)
SKIBOOT_DEPENDENCIES += host-dtc
endif

SKIBOOT_MAKE_OPTS += CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		     AS="$(TARGET_AS)" AR="$(TARGET_AR)" NM="$(TARGET_NM)" \
		     OBJCOPY="$(TARGET_OBJCOPY)" OBJDUMP="$(TARGET_OBJDUMP)" \
		     SIZE="$(TARGET_CROSS)size"

ifeq ($(BR2_PACKAGE_SKIBOOT_EMBED_PAYLOAD),y)
SKIBOOT_MAKE_OPTS += KERNEL=$(BINARIES_DIR)/$(LINUX_IMAGE_NAME)
SKIBOOT_DEPENDENCIES += linux
endif

define SKIBOOT_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) SKIBOOT_VERSION=`cat $(SKIBOOT_VERSION_FILE)` \
		$(MAKE) $(SKIBOOT_MAKE_OPTS) -C $(@D) all

	$(if $(BR2_SKIBOOT_DEVICETREE), \
		$(MAKE) -C $(@D)/external/devicetree)
endef

define SKIBOOT_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 755 $(@D)/skiboot.lid $(BINARIES_DIR)

	$(if $(BR2_SKIBOOT_DEVICETREE), \
		$(INSTALL) -D -m 644 \
			$(@D)/external/devicetree/*.dtb $(BINARIES_DIR))
endef

$(eval $(generic-package))
