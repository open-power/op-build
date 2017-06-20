################################################################################
#
# libflash - builds libflash libraries from skiboot source
#
################################################################################

LIBFLASH_VERSION = 73e1e8a727a9e7179719eb7844bd4248d9890114

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
endef

$(eval $(generic-package))
