################################################################################
#
# alternate-binutils
#
################################################################################

#
# Based on buildroot/package/binutils/binutils.mk
#

ALTERNATE_BINUTILS_VERSION = $(call qstrip,$(BR2_ALTERNATE_BINUTILS_VERSION))
ALTERNATE_BINUTILS_SITE ?= $(BR2_GNU_MIRROR)/binutils
ALTERNATE_BINUTILS_SOURCE ?= binutils-$(ALTERNATE_BINUTILS_VERSION).tar.xz

ALTERNATE_BINUTILS_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)
ALTERNATE_BINUTILS_MAKE_OPTS = LIBS=$(TARGET_NLS_LIBS)
ALTERNATE_BINUTILS_EXTRA_CONFIG_OPTIONS = $(call qstrip,$(BR2_ALTERNATE_BINUTILS_EXTRA_CONFIG_OPTIONS))
ALTERNATE_BINUTILS_CONF_ENV += MAKEINFO=true
ALTERNATE_BINUTILS_MAKE_OPTS += MAKEINFO=true
BINUTILS_INSTALL_OPTS += MAKEINFO=true install

ifeq ($(BR2_PACKAGE_ZLIB),y)
ALTERNATE_BINUTILS_DEPENDENCIES += zlib
endif

HOST_ALTERNATE_BINUTILS_CONF_OPTS = \
	--disable-multilib \
	--disable-werror \
	--prefix="$(HOST_DIR)/alternate-toolchain" \
	--target=$(GNU_TARGET_NAME) \
	--disable-shared \
	--enable-static \
	--with-sysroot=$(STAGING_DIR) \
	--enable-poison-system-directories \
	$(ALTERNATE_BINUTILS_EXTRA_CONFIG_OPTIONS)

ALTERNATE_BINUTILS_MAKE_ENV = $(TARGET_CONFIGURE_ARGS)

define ALTERNATE_BINUTILS_INSTALL_HOST_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/bfd DESTDIR="$(HOST_DIR)/alternate-toolchain" install
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/opcodes DESTDIR="$(HOST_DIR)/alternate-toolchain" install
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/libiberty DESTDIR="$(HOST_DIR)/alternate-toolchain" install
endef

ALTERNATE_BINUTILS_TOOLS = ar as ld ld.bfd nm objcopy objdump ranlib readelf strip
define HOST_ALTERNATE_BINUTILS_FIXUP_HARDLINKS
	$(foreach tool,$(ALTERNATE_BINUTILS_TOOLS),\
		rm -f $(HOST_DIR)/alternate-toolchain/$(GNU_TARGET_NAME)/bin/$(tool) && \
		cp -a $(HOST_DIR)/alternate-toolchain/bin/$(GNU_TARGET_NAME)-$(tool) \
			$(HOST_DIR)/alternate-toolchain/$(GNU_TARGET_NAME)/bin/$(tool)
	)
endef
HOST_ALTERNATE_BINUTILS_POST_INSTALL_HOOKS += HOST_ALTERNATE_BINUTILS_FIXUP_HARDLINKS

$(eval $(host-autotools-package))

