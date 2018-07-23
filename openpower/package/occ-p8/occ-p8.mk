################################################################################
#
# occ for power8
#
################################################################################

OCC_P8_VERSION ?= 28f2cec690b7f19548ce860a8820f519e6c39a6a
OCC_P8_SITE ?= $(call github,open-power,occ,$(OCC_P8_VERSION))
OCC_P8_LICENSE = Apache-2.0

OCC_P8_LICENSE_FILES = src/LICENSE

OCC_P8_INSTALL_IMAGES = YES
OCC_P8_INSTALL_TARGET = NO

OCC_P8_STAGING_DIR = $(STAGING_DIR)/occ

OCC_P8_IMAGE_BIN_PATH = src/image.bin
OCC_P8_DEPENDENCIES = host-binutils host-p8-pore-binutils

define OCC_P8_BUILD_CMDS
        cd $(@D)/src && \
        make POREPATH=$(P8_PORE_BINUTILS_BIN)/bin/ OCC_OP_BUILD=1 CROSS_PREFIX=$(TARGET_CROSS) all && \
        make tracehash && \
        make combineImage
endef

OCC_P8_BUILD_CMDS ?= $(OCC_P8_BUILD_CMDS_P8)

define OCC_P8_INSTALL_IMAGES_CMDS
       mkdir -p $(STAGING_DIR)/occ
       cp $(@D)/$(OCC_P8_IMAGE_BIN_PATH) $(OCC_P8_STAGING_DIR)/$(BR2_OCC_P8_BIN_FILENAME)
endef

$(eval $(generic-package))
