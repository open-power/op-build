OPENPOWER_FFS_VERSION = b28fef379c786c3eb5c36af01ac6ece6163d54b2
OPENPOWER_FFS_SITE = /gsa/ausgsa/home/i/a/iawillia/web/public/openpower/openpower-ffs
OPENPOWER_FFS_SITE_METHOD = git
OPENPOWER_FFS_LICENSE = GPLv2+

define HOST_OPENPOWER_FFS_BUILD_CMDS
	cd $(@D) ; \
	$(HOST_MAKE_ENV) $(MAKE) all
endef

define HOST_OPENPOWER_FFS_INSTALL_CMDS
	$(INSTALL) -D $(@D)/ecc/x86/ecc $(HOST_DIR)/usr/bin/ecc
	$(INSTALL) -D $(@D)/fpart/x86/fpart $(HOST_DIR)/usr/bin/fpart
	$(INSTALL) -D $(@D)/fcp/x86/fcp $(HOST_DIR)/usr/bin/fcp
endef

$(eval $(host-generic-package))
