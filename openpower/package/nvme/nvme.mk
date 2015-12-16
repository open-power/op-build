################################################################################
#
# nvme
#
################################################################################

NVME_VERSION = 798812627467a9999682176ade631ee5b6ea4785
NVME_SITE = https://github.com/linux-nvme/nvme-cli.git
NVME_SITE_METHOD = git
NVME_LICENSE = Common Public License Version 1.0

define NVME_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) \
		INCLUDEDIR="-I." all
endef

define NVME_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/nvme $(TARGET_DIR)/sbin/nvme
endef

$(eval $(generic-package))

