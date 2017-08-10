################################################################################
#
# libflash - builds libflash libraries from skiboot source
#
################################################################################

LIBFLASH_VERSION = v5.7-76-g830fc9a0ed0a
LIBFLASH_SITE = $(call github,open-power,skiboot,$(LIBFLASH_VERSION))
HOST_LIBFLASH_VERSION = 830fc9a0ed0a4066129cfafd1447dc40a66b8700
HOST_LIBFLASH_SITE = $(call github,open-power,skiboot,$(HOST_LIBFLASH_VERSION))

LIBFLASH_INSTALL_STAGING = YES
LIBFLASH_INSTALL_TARGET = YES

LIBFLASH_LICENSE_FILES = LICENCE

LIBFLASH_MAKE_OPTS += CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		     AS="$(TARGET_AS)" AR="$(TARGET_AR)" NM="$(TARGET_NM)" \
		     OBJCOPY="$(TARGET_OBJCOPY)" OBJDUMP="$(TARGET_OBJDUMP)" \
		     SIZE="$(TARGET_CROSS)size"

define LIBFLASH_BUILD_CMDS
	PREFIX=$(STAGING_DIR)/usr SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	       $(MAKE1) $(LIBFLASH_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) \
	       -C $(@D)/external/shared
endef

define HOST_LIBFLASH_BUILD_CMDS
    $(HOST_MAKE_ENV) $(MAKE) -C $(@D)/external/pflash
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

define HOST_LIBFLASH_INSTALL_CMDS
    $(INSTALL) $(@D)/external/pflash/pflash $(HOST_DIR)/usr/bin/pflash
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
