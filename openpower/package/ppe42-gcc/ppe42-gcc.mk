################################################################################
#
# ppe42-gcc
#
################################################################################

PPE42_GCC_VERSION ?= 53cbf8d57945ac491b70865936b5ee136ec75ccb
PPE42_GCC_SITE ?= $(call github,open-power,ppe42-gcc,$(PPE42_GCC_VERSION))
PPE42_GCC_LICENSE = GPLv3+

PPE42_GCC_DEPENDENCIES = ppe42-binutils

PPE42_GCC_DIR = $(STAGING_DIR)/ppe42-binutils
PPE42_GCC_BIN = $(STAGING_DIR)/ppe42-binutils/linux

define HOST_PPE42_GCC_BUILD_CMDS
        cd $(@D) && \
        ./configure --prefix=$(PPE42_GCC_DIR) \
                    --exec-prefix=$(PPE42_GCC_BIN) \
					--target=powerpc-eabi \
					--without-headers \
					--with-newlib \
					--with-gnu-as \
					--with-gnu-ld \
					--with-gmp=$(HOST_DIR)/usr \
					--with-mpfr=$(HOST_DIR)/usr \
					&& \
        make configure-host && \
        make all-gcc LDFLAGS=-all-static
endef

define HOST_PPE42_GCC_INSTALL_CMDS
        bash -c 'cd $(@D) && make install-gcc'
endef

$(eval $(host-generic-package))
