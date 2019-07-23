################################################################################
#
# openpower_pnor_util
#
################################################################################

HOST_OPENPOWER_PNOR_UTIL_VERSION ?= adf91f58dac9f177a061d9b206d853a9db3db70a
HOST_OPENPOWER_PNOR_UTIL_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_PNOR_UTIL_VERSION))
HOST_OPENPOWER_PNOR_UTIL_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_PNOR_UTIL_INSTALL_CMDS
	$(INSTALL) -D $(@D)/generate-tar $(HOST_DIR)/usr/bin/generate-tar
endef

OPENPOWER_PNOR_UTIL_LICENSE = Apache-2.0

$(eval $(host-generic-package))
