################################################################################
#
# openpower_vpnor
#
################################################################################

HOST_OPENPOWER_VPNOR_VERSION ?= 0e30f86cb44f3ab0aa4080faf32eb4bf2a9b12b2
HOST_OPENPOWER_VPNOR_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_VPNOR_VERSION))
HOST_OPENPOWER_VPNOR_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_VPNOR_INSTALL_CMDS
    $(INSTALL) -D $(@D)/generate-squashfs $(HOST_DIR)/usr/bin/generate-squashfs
endef

$(eval $(host-generic-package))
