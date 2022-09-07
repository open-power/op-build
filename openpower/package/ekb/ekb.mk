################################################################################
#
# ekb
#
################################################################################

EKB_VERSION = $(call qstrip,$(BR2_EKB_VERSION))
EKB_SITE = $(call github,open-power,pub-ekb,$(EKB_VERSION))

EKB_INSTALL_STAGING = YES
EKB_INSTALL_TARGET = NO

EKB_STAGING_DIR = $(STAGING_DIR)/ekb/

ifeq ($(BR2_OPENPOWER_POWER10),y)
EKB_HWP_ATTRS_XML_FILES = chips/p10/procedures/xml/attribute_info/p10_clock_attributes.xml \
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

define EKB_INSTALL_STAGING_CMDS
		# Creating ekb staging directory
		mkdir -p $(EKB_STAGING_DIR)
		# Copying all required hwps attributes xml file with respective directory structures
		cd $(@D); cp --parents $(EKB_HWP_ATTRS_XML_FILES) $(EKB_STAGING_DIR)
endef

$(eval $(generic-package))
