################################################################################
#
# openpower_vpnor
#
################################################################################

HOST_OPENPOWER_VPNOR_VERSION ?= 643e730e3b9818bdd878eebee209b268c234fc65
HOST_OPENPOWER_VPNOR_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_VPNOR_VERSION))
HOST_OPENPOWER_VPNOR_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_VPNOR_INSTALL_CMDS
    $(INSTALL) -D $(@D)/generate-squashfs $(HOST_DIR)/usr/bin/generate-squashfs
endef

$(eval $(host-generic-package))
