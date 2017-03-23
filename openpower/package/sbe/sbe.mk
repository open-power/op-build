################################################################################
#
# SBE
#
################################################################################

#SBE_VERSION ?= c48c01ff77c6e0b41c24308b21b6001b72d20c65
#SBE_SITE ?= $(call github,open-power,sbe,$(SBE_VERSION))
SBE_SITE_METHOD = git
SBE_SITE = ssh://spashabk-in@ralgit01.raleigh.ibm.com:29418/hw/ppe
SBE_VERSION = refs/changes/48/38348/1

SBE_LICENSE = Apache-2.0
SBE_DEPENDENCIES = host-ppe42-gcc

SBE_INSTALL_IMAGES = YES
SBE_INSTALL_TARGET = NO

define SBE_BUILD_CMDS
		bash -c 'cd $(@D)  && make LD_LIBRARY_PATH=$(HOST_DIR)/usr/lib CROSS_COMPILER_PATH=$(PPE42_GCC_BIN)'
endef

define SBE_INSTALL_IMAGES_CMDS
		python $(@D)/src/build/sbeOpDistribute.py --root_dir=$(BR2_EXTERNAL_OP_BUILD_PATH) --staging_dir=$(STAGING_DIR) --img_dir=$(@D)/images --host_dir=$(HOST_DIR)
endef

$(eval $(generic-package))
