################################################################################
#
# openpower_vpnor
#
################################################################################

HOST_OPENPOWER_VPNOR_VERSION ?= 5c90711a8aaa6b1d760388a5116e36831ce5e7ab
HOST_OPENPOWER_VPNOR_SITE ?= $(call github,openbmc,openpower-pnor-code-mgmt,$(HOST_OPENPOWER_VPNOR_VERSION))
HOST_OPENPOWER_VPNOR_DEPENDENCIES = host-squashfs host-libflash

define HOST_OPENPOWER_VPNOR_INSTALL_CMDS
    $(INSTALL) -D $(@D)/generate-squashfs $(HOST_DIR)/usr/bin/generate-squashfs
endef

$(eval $(host-generic-package))
