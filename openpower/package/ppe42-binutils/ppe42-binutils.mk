################################################################################
#
# ppe42-binutils
#
################################################################################

PPE42_BINUTILS_VERSION ?= c615a89c5beb032cbb00bf0c3e670319b2bbd4f5
PPE42_BINUTILS_SITE ?= $(call github,open-power,ppe42-binutils,$(PPE42_BINUTILS_VERSION))
PPE42_BINUTILS_LICENSE = GPLv3+

PPE42_BINUTILS_DEPENDENCIES = host-binutils

PPE42_BINUTILS_DIR = $(HOST_DIR)/$(PPE42_TOOLCHAIN_DIR)
PPE42_BINUTILS_BIN = $(HOST_DIR)/$(PPE42_TOOLCHAIN_BIN)

define HOST_PPE42_BINUTILS_BUILD_CMDS
        cd $(@D) && \
        ./configure --prefix=$(PPE42_BINUTILS_DIR) \
                    --exec-prefix=$(PPE42_BINUTILS_BIN) \
					--target=powerpc-eabi \
					--enable-shared \
					--enable-64-bit-bfd \
					&& \
        $(MAKE) configure-host && \
        $(MAKE) LDFLAGS=-all-static CFLAGS=-Wno-error
endef

define HOST_PPE42_BINUTILS_INSTALL_CMDS
        bash -c 'cd $(@D) && make install'
endef

$(eval $(host-generic-package))
