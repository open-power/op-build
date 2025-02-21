################################################################################
#
# ekb
#
################################################################################

EKB_P11_VERSION = $(call qstrip,$(BR2_EKB_P11_VERSION))

#Public
EKB_P11_SITE = $(call github,open-power,pub-ekb,$(EKB_P11_VERSION))

#Private
#EKB_P11_SITE ?= git@github.ibm.com:open-power/pub-ekb.git
#EKB_P11_SITE_METHOD ?= git


EKB_P11_INSTALL_STAGING = YES
EKB_P11_INSTALL_TARGET = NO

EKB_P11_STAGING_DIR = $(STAGING_DIR)/ekb/

ifeq ($(BR2_OPENPOWER_POWER11),y)
EKB_P11_HWP_ATTRS_XML_FILES = chips/p10/procedures/xml/attribute_info/p10_clock_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_freq_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_ipl_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_nest_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_pervasive_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_runn_attributes.xml \
           chips/p10/procedures/xml/attribute_info/p10_bars_attributes.xml \
           chips/p10/procedures/xml/attribute_info/pm_plat_attributes.xml \
           hwpf/fapi2/xml/attribute_info/unit_attributes.xml \
           hwpf/fapi2/xml/attribute_info/common_attributes.xml \
           hwpf/fapi2/xml/attribute_info/chip_attributes.xml
endif

define EKB_P11_INSTALL_STAGING_CMDS
		# Creating ekb staging directory
		mkdir -p $(EKB_P11_STAGING_DIR)
		# Copying all required hwps attributes xml file with respective directory structures
		cd $(@D); cp --parents $(EKB_P11_HWP_ATTRS_XML_FILES) $(EKB_P11_STAGING_DIR)
endef

$(eval $(generic-package))
