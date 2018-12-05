################################################################################
#
# libflash - builds libflash libraries from skiboot source
#
################################################################################

LIBFLASH_VERSION = v6.2-rc1
LIBFLASH_SITE = $(call github,open-power,skiboot,$(LIBFLASH_VERSION))

LIBFLASH_INSTALL_STAGING = YES
LIBFLASH_INSTALL_TARGET = YES

LIBFLASH_LICENSE_FILES = LICENCE

LIBFLASH_MAKE_OPTS += CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		     AS="$(TARGET_AS)" AR="$(TARGET_AR)" NM="$(TARGET_NM)" \
		     OBJCOPY="$(TARGET_OBJCOPY)" OBJDUMP="$(TARGET_OBJDUMP)" \
		     SIZE="$(TARGET_CROSS)size"

LIBFLASH_MAKE_ENV = \
	SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	       $(MAKE1) $(LIBFLASH_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS)


define LIBFLASH_BUILD_CMDS
	PREFIX=$(STAGING_DIR)/usr $(LIBFLASH_MAKE_ENV) -C $(@D)/external/shared
	$(if $(BR2_PACKAGE_PFLASH),
		PREFIX=$(STAGING_DIR)/usr $(LIBFLASH_MAKE_ENV) \
		       -C $(@D)/external/pflash)
	$(if $(BR2_PACKAGE_OPAL_GARD),
		PREFIX=$(STAGING_DIR)/usr $(LIBFLASH_MAKE_ENV) \
		       -C $(@D)/external/gard)
endef

define HOST_LIBFLASH_BUILD_CMDS
    $(HOST_MAKE_ENV) SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	    $(MAKE) -C $(@D)/external/pflash
    $(HOST_MAKE_ENV) SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	    $(MAKE) -C $(@D)/external/gard
    $(HOST_MAKE_ENV) SKIBOOT_VERSION=$(LIBFLASH_VERSION) \
	    $(MAKE) -C $(@D)/external/ffspart
endef

define LIBFLASH_INSTALL_STAGING_CMDS
	PREFIX=$(STAGING_DIR)/usr $(LIBFLASH_MAKE_ENV) -C $(@D)/external/shared \
	       install
endef

define LIBFLASH_INSTALL_TARGET_CMDS
	PREFIX=$(TARGET_DIR)/usr $(LIBFLASH_MAKE_ENV) -C $(@D)/external/shared \
	       install-lib
	$(if $(BR2_PACKAGE_PFLASH),
		DESTDIR=$(TARGET_DIR) $(LIBFLASH_MAKE_ENV) \
		       -C $(@D)/external/pflash install)
	$(if $(BR2_PACKAGE_OPAL_GARD),
		$(INSTALL) $(@D)/external/gard/gard $(TARGET_DIR)/usr/bin/opal-gard)
endef

define HOST_LIBFLASH_INSTALL_CMDS
    $(INSTALL) $(@D)/external/pflash/pflash $(HOST_DIR)/usr/bin/pflash
    $(INSTALL) $(@D)/external/ffspart/ffspart $(HOST_DIR)/usr/bin/ffspart
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
