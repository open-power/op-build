################################################################################
#
# p8-pore-binutils
#
################################################################################

P8_PORE_BINUTILS_VERSION ?= 91069b732e4c253055cd94fff6ad179116563df9
P8_PORE_BINUTILS_SITE ?= $(call github,open-power,p8-pore-binutils,$(P8_PORE_BINUTILS_VERSION))
P8_PORE_BINUTILS_LICENSE = GPLv3+
P8_PORE_BINUTILS_LICENSE_FILES = COPYING3 COPYING.LIB
P8_PORE_BINUTILS_PROVIDES = p8-pore-toolchain
HOST_P8_PORE_BINUTILS_DEPENDENCIES = host-binutils

P8_PORE_BINUTILS_DIR = $(HOST_DIR)/$(P8_PORE_TOOLCHAIN_DIR)
P8_PORE_BINUTILS_BIN = $(HOST_DIR)/$(P8_PORE_TOOLCHAIN_BIN)

define HOST_P8_PORE_BINUTILS_BUILD_CMDS
        cd $(@D) && \
        ./configure --prefix=$(P8_PORE_BINUTILS_DIR) \
                    --exec-prefix=$(P8_PORE_BINUTILS_BIN) \
                    --target=pore-elf64 && \
        make configure-host && \
        make CFLAGS=-Wno-error LDFLAGS=-all-static
endef

define HOST_P8_PORE_BINUTILS_INSTALL_CMDS
        bash -c 'cd $(@D) && make install'
endef

$(eval $(host-generic-package))
