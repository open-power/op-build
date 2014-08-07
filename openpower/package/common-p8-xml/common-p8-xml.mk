################################################################################
#
# common-p8-xml
#
################################################################################

COMMON_P8_XML_VERSION ?= 1afe70931836abbe896220e3824cbbeb730ee5d7
COMMON_P8_XML_SITE ?= $(call github,open-power,common-p8-xml,$(COMMON_P8_XML_VERSION))

COMMON_P8_XML_LICENSE = Apache-2.0
COMMON_P8_XML_DEPENDENCIES =

COMMON_P8_XML_INSTALL_IMAGES = YES
COMMON_P8_XML_INSTALL_TARGET = NO

XML_INSTALL_DIRECTORY=$(STAGING_DIR)/openpower_mrw_scratch/

define COMMON_P8_XML_INSTALL_IMAGES_CMDS
        bash -c 'mkdir -p $(XML_INSTALL_DIRECTORY) && cp -r $(@D)/* $(XML_INSTALL_DIRECTORY)'
endef

$(eval $(generic-package))
