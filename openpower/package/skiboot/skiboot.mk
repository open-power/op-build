################################################################################
#
# skiboot
#
################################################################################

SKIBOOT_VERSION = $(call qstrip,$(BR2_SKIBOOT_VERSION))

SKIBOOT_SITE = $(call github,open-power,skiboot,$(SKIBOOT_VERSION))
SKIBOOT_LICENSE = Apache-2.0
SKIBOOT_LICENSE_FILES = LICENCE
SKIBOOT_INSTALL_IMAGES = YES
SKIBOOT_INSTALL_TARGET = NO

SKIBOOT_MAKE_OPTS += CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		     AS="$(TARGET_AS)" AR="$(TARGET_AR)" NM="$(TARGET_NM)" \
		     OBJCOPY="$(TARGET_OBJCOPY)" OBJDUMP="$(TARGET_OBJDUMP)" \
		     SIZE="$(TARGET_CROSS)size"

ifeq ($(BR2_TARGET_SKIBOOT_EMBED_PAYLOAD),y)
SKIBOOT_MAKE_OPTS += KERNEL="$(BINARIES_DIR)/$(LINUX_IMAGE_NAME)"

ifeq ($(BR2_TARGET_ROOTFS_INITRAMFS),y)
SKIBOOT_DEPENDENCIES += linux-rebuild-with-initramfs
else
SKIBOOT_DEPENDENCIES += linux
endif

endif

define SKIBOOT_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) SKIBOOT_VERSION=`cat $(SKIBOOT_VERSION_FILE)` \
		$(MAKE) $(SKIBOOT_MAKE_OPTS) -C $(@D) all
endef

define SKIBOOT_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 755 $(@D)/skiboot.lid $(BINARIES_DIR)
endef

$(eval $(generic-package))
