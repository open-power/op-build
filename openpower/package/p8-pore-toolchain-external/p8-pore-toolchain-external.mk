################################################################################
#
# p8-pore-toolchain-external
#
################################################################################
P8_PORE_TOOLCHAIN_EXTERNAL_REDISTRIBUTE = NO
P8_PORE_TOOLCHAIN_EXTERNAL_SITE =
P8_PORE_TOOLCHAIN_EXTERNAL_SOURCE =
P8_PORE_TOOLCHAIN_EXTERNAL_PROVIDES = p8-pore-toolchain
P8_PORE_TOOLCHAIN_EXTERNAL_PATH = \
	$(call qstrip,$(BR2_P8_PORE_TOOLCHAIN_EXTERNAL_PATH))/$(P8_PORE_TOOLCHAIN_DIR)

define HOST_P8_PORE_TOOLCHAIN_EXTERNAL_CONFIGURE_CMDS
	test -e $(P8_PORE_TOOLCHAIN_EXTERNAL_PATH)
endef

define HOST_P8_PORE_TOOLCHAIN_EXTERNAL_INSTALL_CMDS
	ln -snf $(P8_PORE_TOOLCHAIN_EXTERNAL_PATH) $(HOST_DIR)/$(P8_PORE_TOOLCHAIN_DIR)

endef

$(eval $(host-generic-package))
