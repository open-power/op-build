################################################################################
#
# openpower_targeting
#
################################################################################

OPENPOWER_TARGETING_VERSION ?= e1376ce4b33d303f342e26b88d6b2fa53fcfba0c
OPENPOWER_TARGETING_SITE ?= $(call github,open-power,hostboot-targeting,$(OPENPOWER_TARGETING_VERSION))

OPENPOWER_TARGETING_LICENSE = Apache-2.0
OPENPOWER_TARGETING_DEPENDENCIES = hostboot-install-images

OPENPOWER_TARGETING_INSTALL_IMAGES = YES
OPENPOWER_TARGETING_INSTALL_TARGET = NO

define OPENPOWER_TARGETING_INSTALL_IMAGES_CMDS
        mkdir -p $(STAGING_DIR)/openpower_targeting/;

        $(STAGING_DIR)/hostboot_build_images/mergexml.sh \
            $(@D)/$(BR2_OPENPOWER_TARGETING_SYSTEM_XML_FILENAME) \
            $(STAGING_DIR)/hostboot_build_images/attribute_types.xml \
            $(STAGING_DIR)/hostboot_build_images/attribute_types_hb.xml \
            $(STAGING_DIR)/hostboot_build_images/target_types_merged.xml \
            $(STAGING_DIR)/hostboot_build_images/target_types_hb.xml \
            $(@D)/$(BR2_OPENPOWER_TARGETING_MRW_XML_FILENAME) > $(STAGING_DIR)/openpower_targeting/temporary_hb.hb.xml;

        $(STAGING_DIR)/hostboot_build_images/xmltohb.pl \
            --hb-xml-file=$(STAGING_DIR)/openpower_targeting/temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(STAGING_DIR)/hostboot_build_images/fapiattrs.xml \
            --src-output-dir=none \
            --img-output-dir=$(STAGING_DIR)/openpower_targeting/ \
            --vmm-consts-file=$(STAGING_DIR)/hostboot_build_images/vmmconst.h \
            --noshort-enums

        mv $(STAGING_DIR)/openpower_targeting/targeting.bin $(STAGING_DIR)/openpower_targeting/$(BR2_OPENPOWER_TARGETING_BIN_FILENAME)
endef

$(eval $(generic-package))
