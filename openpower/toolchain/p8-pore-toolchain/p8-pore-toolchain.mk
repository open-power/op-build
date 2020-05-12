################################################################################
#
# p8-pore-toolchain
#
################################################################################
P8_PORE_TOOLCHAIN_DIR = $(STAGING_SUBDIR)/p8-pore-toolchain
P8_PORE_TOOLCHAIN_BIN = $(STAGING_SUBDIR)/p8-pore-toolchain/linux

$(eval $(host-virtual-package))
