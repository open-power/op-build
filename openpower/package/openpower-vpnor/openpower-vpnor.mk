################################################################################
#
# openpower_vpnor
#
################################################################################

HOST_OPENPOWER_VPNOR_VERSION ?= c39d923fee581533775e37be3f59f77c021718ee
HOST_OPENPOWER_VPNOR_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_VPNOR_VERSION))
HOST_OPENPOWER_VPNOR_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_VPNOR_INSTALL_CMDS
    $(INSTALL) -D $(@D)/generate-squashfs $(HOST_DIR)/usr/bin/generate-squashfs
endef

$(eval $(host-generic-package))
