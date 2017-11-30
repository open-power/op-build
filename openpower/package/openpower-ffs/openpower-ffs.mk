OPENPOWER_FFS_VERSION ?= 1ccd69266b2b71113d17de0d799e0de64aac2fb5
OPENPOWER_FFS_SITE ?= $(call github,open-power,ffs,$(OPENPOWER_FFS_VERSION))
OPENPOWER_FFS_LICENSE = GPLv2+
OPENPOWER_FFS_LICENSE_FILES = LICENSE

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
