################################################################################
#
# ppe42-binutils
#
################################################################################

PPE42_BINUTILS_VERSION ?= 906e4d95196ae94177e3fcd838b7c07b55c7c93a
PPE42_BINUTILS_SITE ?= $(call github,open-power,ppe42-binutils,$(PPE42_BINUTILS_VERSION))
PPE42_BINUTILS_LICENSE = GPLv3+

PPE42_BINUTILS_DEPENDENCIES = host-binutils

PPE42_BINUTILS_DIR = $(STAGING_DIR)/ppe42-binutils
PPE42_BINUTILS_BIN = $(STAGING_DIR)/ppe42-binutils/linux

define HOST_PPE42_BINUTILS_BUILD_CMDS
        cd $(@D) && \
        ./configure --prefix=$(PPE42_BINUTILS_DIR) \
                    --exec-prefix=$(PPE42_BINUTILS_BIN) \
					--target=powerpc-eabi \
					--enable-shared \
					--enable-64-bit-bfd \
					&& \
        make configure-host && \
        make LDFLAGS=-all-static
endef

define HOST_PPE42_BINUTILS_INSTALL_CMDS
        bash -c 'cd $(@D) && make install'
endef

$(eval $(host-generic-package))
