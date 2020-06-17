################################################################################
#
# openpower_pnor_util
#
################################################################################

HOST_OPENPOWER_PNOR_UTIL_VERSION ?= 647d6134d448178e6b32892322596a5cc3d78b2d
HOST_OPENPOWER_PNOR_UTIL_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_PNOR_UTIL_VERSION))
HOST_OPENPOWER_PNOR_UTIL_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_PNOR_UTIL_INSTALL_CMDS
	$(INSTALL) -D $(@D)/generate-tar $(HOST_DIR)/usr/bin/generate-tar
endef

OPENPOWER_PNOR_UTIL_LICENSE = Apache-2.0

$(eval $(host-generic-package))
