################################################################################
#
# p8-pore-binutils
#
################################################################################

P8_PORE_BINUTILS_VERSION ?= 94a1a56cb3ce72a2d6202ab54206912cf9e1feb1
P8_PORE_BINUTILS_SITE ?= $(call github,open-power,p8-pore-inutils,$(P8_PORE_BINUTILS_VERSION))
P8_PORE_BINUTILS_LICENSE = Apache-2.0
P8_PORE_BINUTILS_DEPENDENCIES = host-binutils

P8_PORE_BINUTILS_INSTALL_IMAGES = YES
P8_PORE_BINUTILS_INSTALL_TARGET = NO

P8_PORE_BINUTILS_DIR = $(STAGING_DIR)/p8-pore-binutils
P8_PORE_BINUTILS_BIN = $(STAGING_DIR)/p8-pore-binutils/linux

define P8_PORE_BINUTILS_BUILD_CMDS
        cd $(@D) && \
        ./configure --prefix=$(P8_PORE_BINUTILS_DIR) \
                    --exec-prefix=$(P8_PORE_BINUTILS_BIN) \
                    --target=pore-elf64 \
                    --build=i386-unknown-linux-gnu && \
        make configure-host && \
        make LDFLAGS=-all-static
endef

define P8_PORE_BINUTILS_INSTALL_IMAGES_CMDS
        bash -c 'cd $(@D) && make install'
endef

$(eval $(generic-package))
