################################################################################
#
# ppe42-toolchain-external
#
################################################################################
PPE42_TOOLCHAIN_EXTERNAL_REDISTRIBUTE = NO
PPE42_TOOLCHAIN_EXTERNAL_SITE =
PPE42_TOOLCHAIN_EXTERNAL_SOURCE =
PPE42_TOOLCHAIN_EXTERNAL_PROVIDES = ppe42-toolchain
PPE42_TOOLCHAIN_EXTERNAL_PATH = \
	$(call qstrip,$(BR2_PPE42_TOOLCHAIN_EXTERNAL_PATH))/$(PPE42_TOOLCHAIN_DIR)

define HOST_PPE42_TOOLCHAIN_EXTERNAL_CONFIGURE_CMDS
        test -e $(PPE42_TOOLCHAIN_EXTERNAL_PATH)
endef

define HOST_PPE42_TOOLCHAIN_EXTERNAL_INSTALL_CMDS
        ln -snf $(PPE42_TOOLCHAIN_EXTERNAL_PATH) $(HOST_DIR)/$(PPE42_TOOLCHAIN_DIR)

endef

$(eval $(host-generic-package))

