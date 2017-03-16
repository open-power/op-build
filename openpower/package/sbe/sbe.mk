################################################################################
#
# SBE
#
################################################################################

#SBE_VERSION = sgupta
#SBE_SITE = /esw/san2/sgupta2m/sbeTest/ppe/ppe
#SBE_SITE_METHOD = local
SBE_VERSION ?= c48c01ff77c6e0b41c24308b21b6001b72d20c65
SBE_SITE ?= $(call github,open-power,sbe,$(SBE_VERSION))


SBE_LICENSE = Apache-2.0
SBE_DEPENDENCIES = host-ppe42-gcc

SBE_INSTALL_IMAGES = YES
SBE_INSTALL_TARGET = NO

define SBE_BUILD_CMDS
		bash -c 'cd $(@D)  && make LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib PPE42PATH=$(PPE42_GCC_BIN) install'
endef

define HOST_PPE42_TEST_INSTALL_CMDS
        bash -c 'cd $(@D)
endef

$(eval $(generic-package))
