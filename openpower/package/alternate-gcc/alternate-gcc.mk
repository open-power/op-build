################################################################################
#
# alternate-gcc
#
################################################################################

#
# Based on buildroot/package/gcc/*.mk, but trying to simplify since we're not
# (yet) going for a general scenario here
#

ALTERNATE_GCC_VERSION = $(call qstrip,$(BR2_ALTERNATE_GCC_VERSION))
ALTERNATE_GCC_SITE = $(BR2_GNU_MIRROR:/=)/gcc/gcc-$(ALTERNATE_GCC_VERSION)
ALTERNATE_GCC_SOURCE = gcc-$(ALTERNATE_GCC_VERSION).tar.xz

HOST_ALTERNATE_GCC_SUBDIR = build

HOST_ALTERNATE_GCC_DEPENDENCIES = \
	host-alternate-binutils \
	host-gmp \
	host-mpc \
	host-mpfr \
	$(BR_LIBC)

HOST_ALTERNATE_GCC_EXCLUDES = \
	libjava/* libgo/*

define HOST_ALTERNATE_GCC_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef

HOST_ALTERNATE_GCC_CONF_OPTS += \
	$(call qstrip,$(BR2_ALTERNATE_GCC_EXTRA_CONFIG_OPTIONS))

define  HOST_ALTERNATE_GCC_CONFIGURE_CMDS
	(cd $(HOST_ALTERNATE_GCC_SRCDIR) && rm -rf config.cache; \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CXXFLAGS)" \
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		MAKEINFO=missing \
		./configure \
		--prefix="$(HOST_DIR)/alternate-toolchain" \
		--enable-static \
		--target=$(GNU_TARGET_NAME) \
		--with-sysroot=$(STAGING_DIR) \
		--enable-__cxa_atexit \
		--with-gnu-ld \
		--disable-libssp \
		--disable-multilib \
		--disable-decimal-float \
		--with-gmp=$(HOST_DIR) \
		--with-mpc=$(HOST_DIR) \
		--with-mpfr=$(HOST_DIR) \
		--enable-languages="c,c++" \
		--with-build-time-tools=$(HOST_DIR)/alternate-toolchain/$(GNU_TARGET_NAME)/bin \
		--enable-shared \
		$(QUIET) $(HOST_ALTERNATE_GCC_CONF_OPTS) \
	)
endef

HOST_ALTERNATE_GCC_PRE_CONFIGURE_HOOKS += HOST_ALTERNATE_GCC_CONFIGURE_SYMLINK

$(eval $(host-autotools-package))
