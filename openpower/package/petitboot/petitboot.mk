################################################################################
#
# petitboot
#
################################################################################

PETITBOOT_VERSION = 72928ed32ab3684be74e4a3b90329dee7cfa6bbb
PETITBOOT_SITE ?= $(call github,open-power,petitboot,$(PETITBOOT_VERSION))
PETITBOOT_DEPENDENCIES = ncurses udev host-bison host-flex lvm2
PETITBOOT_LICENSE = GPLv2
PETITBOOT_LICENSE_FILES = COPYING

PETITBOOT_AUTORECONF = YES
PETITBOOT_AUTORECONF_OPTS = -i
PETITBOOT_GETTEXTIZE = YES
PETITBOOT_CONF_OPTS += --with-ncurses --without-twin-x11 --without-twin-fbdev \
	      --localstatedir=/var \
	      HOST_PROG_KEXEC=/usr/sbin/kexec \
	      HOST_PROG_SHUTDOWN=/usr/libexec/petitboot/bb-kexec-reboot \
	      $(if $(BR2_PACKAGE_BUSYBOX),--with-tftp=busybox)

ifdef PETITBOOT_DEBUG
PETITBOOT_CONF_OPTS += --enable-debug
endif

ifeq ($(BR2_PACKAGE_PETITBOOT_MTD),y)
PETITBOOT_CONF_OPTS += --enable-mtd
PETITBOOT_DEPENDENCIES += libflash
PETITBOOT_CPPFLAGS += -I$(STAGING_DIR)
PETITBOOT_LDFLAGS += -L$(STAGING_DIR)
endif

ifeq ($(BR2_PACKAGE_NCURSES_WCHAR),y)
PETITBOOT_CONF_OPTS += --with-ncursesw MENU_LIB=-lmenuw FORM_LIB=-lformw
endif

PETITBOOT_PRE_CONFIGURE_HOOKS += PETITBOOT_PRE_CONFIGURE_BOOTSTRAP

define PETITBOOT_POST_INSTALL
	$(INSTALL) -D -m 0755 $(@D)/utils/bb-kexec-reboot \
		$(TARGET_DIR)/usr/libexec/petitboot
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/petitboot/boot.d
	$(INSTALL) -D -m 0755 $(@D)/utils/hooks/01-create-default-dtb \
		$(TARGET_DIR)/etc/petitboot/boot.d/
	$(INSTALL) -D -m 0755 $(@D)/utils/hooks/20-set-stdout \
		$(TARGET_DIR)/etc/petitboot/boot.d/
	$(INSTALL) -D -m 0755 $(@D)/utils/hooks/90-sort-dtb \
		$(TARGET_DIR)/etc/petitboot/boot.d/
	$(INSTALL) -D -m 0755 $(@D)/utils/hooks/30-add-offb \
		$(TARGET_DIR)/etc/petitboot/boot.d/

	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/S14silence-console \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/S15pb-discover \
		$(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/kexec-restart \
		$(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/petitboot-console-ui.rules \
		$(TARGET_DIR)/etc/udev/rules.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/removable-event-poll.rules \
		$(TARGET_DIR)/etc/udev/rules.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/63-md-raid-arrays.rules \
		$(TARGET_DIR)/etc/udev/rules.d/
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/petitboot/65-md-incremental.rules \
		$(TARGET_DIR)/etc/udev/rules.d/

	ln -sf /usr/sbin/pb-udhcpc \
		$(TARGET_DIR)/usr/share/udhcpc/default.script.d/

	$(MAKE) -C $(@D)/po DESTDIR=$(TARGET_DIR) install
endef

PETITBOOT_POST_INSTALL_TARGET_HOOKS += PETITBOOT_POST_INSTALL

$(eval $(autotools-package))
