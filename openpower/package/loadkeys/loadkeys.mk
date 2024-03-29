################################################################################
#
# loadkeys - Custom installer for the kbd package
#
################################################################################

LOADKEYS_VERSION = 2.5.1
LOADKEYS_SOURCE = kbd-$(LOADKEYS_VERSION).tar.xz
LOADKEYS_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kbd
LOADKEYS_CONF_OPTS = \
		--disable-vlock \
		--disable-tests
LOADKEYS_DEPENDENCIES = \
		$(TARGET_NLS_DEPENDENCIES) \
		host-pkgconf
LOADKEYS_LICENSE = GPL-2.0+
LOADKEYS_LICENSE_FILES = COPYING CREDITS
LOADKEYS_INSTALL_STAGING = NO
LOADKEYS_INSTALL_TARGET = YES

define LOADKEYS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/loadkeys \
		$(TARGET_DIR)/usr/bin/
endef

define LOADKEYS_POST_INSTALL
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_OP_BUILD_PATH)/package/loadkeys/S16-keymap \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_OP_BUILD_PATH)/package/loadkeys/backtab-keymap \
		$(TARGET_DIR)/etc/kbd/config
endef

LOADKEYS_POST_INSTALL_TARGET_HOOKS += LOADKEYS_POST_INSTALL

$(eval $(autotools-package))
