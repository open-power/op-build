################################################################################
#
# libflash - builds libflash libraries from skiboot source
#
################################################################################

LIBFLASH_VERSION = b2649b822ab57ab06f0028d8343320ae6e11cc50

LIBFLASH_SITE = $(call github,open-power,skiboot,$(LIBFLASH_VERSION))
LIBFLASH_INSTALL_STAGING = YES
LIBFLASH_INSTALL_TARGET = YES

LIBFLASH_MAKE_OPTS += CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		     AS="$(TARGET_AS)" AR="$(TARGET_AR)" NM="$(TARGET_NM)" \
		     OBJCOPY="$(TARGET_OBJCOPY)" OBJDUMP="$(TARGET_OBJDUMP)" \
		     SIZE="$(TARGET_CROSS)size"

define LIBFLASH_BUILD_CMDS
	PREFIX=$(STAGING_DIR)/usr SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	       $(MAKE1) $(LIBFLASH_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) \
	       -C $(@D)/external/shared
endef

define LIBFLASH_INSTALL_STAGING_CMDS
	PREFIX=$(STAGING_DIR)/usr SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	       $(MAKE1) $(LIBFLASH_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) \
	       -C $(@D)/external/shared install
endef

define LIBFLASH_INSTALL_TARGET_CMDS
	PREFIX=$(TARGET_DIR)/usr SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	       $(MAKE1) $(LIBFLASH_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) \
	       -C $(@D)/external/shared install-lib
endef

$(eval $(generic-package))
