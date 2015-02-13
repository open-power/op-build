################################################################################
#
# palmetto_xml
#
################################################################################

PALMETTO_XML_VERSION = 283937a8237092addf07b7ab4c436337bab89e37
PALMETTO_XML_SITE = $(call github,open-power,palmetto-xml,$(PALMETTO_XML_VERSION))

PALMETTO_XML_LICENSE = Apache-2.0
PALMETTO_XML_DEPENDENCIES = hostboot-install-images openpower-mrw-install-images common-p8-xml-install-images

PALMETTO_XML_INSTALL_IMAGES = YES
PALMETTO_XML_INSTALL_TARGET = NO

MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

define PALMETTO_XML_BUILD_CMDS
        # copy the palmetto xml where the common lives
        bash -c 'mkdir -p $(MRW_SCRATCH) && cp -r $(@D)/* $(MRW_SCRATCH)'

        # generate the system mrw xml
        perl -I $(MRW_HB_TOOLS) \
        $(MRW_HB_TOOLS)/processMrw.pl -x $(MRW_SCRATCH)/palmetto.xml
endef

define PALMETTO_XML_INSTALL_IMAGES_CMDS

        # merge in any system specific attributes, hostboot attributes
        $(MRW_HB_TOOLS)/mergexml.sh $(MRW_SCRATCH)/$(BR2_PALMETTO_SYSTEM_XML_FILENAME) \
            $(MRW_HB_TOOLS)/attribute_types.xml \
            $(MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(MRW_HB_TOOLS)/target_types_merged.xml \
            $(MRW_HB_TOOLS)/target_types_hb.xml \
            $(MRW_SCRATCH)/$(BR2_PALMETTO_MRW_XML_FILENAME) > $(MRW_HB_TOOLS)/temporary_hb.hb.xml;

        # creating the targeting binary
        $(MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(MRW_HB_TOOLS)/temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=none \
            --img-output-dir=$(MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(MRW_HB_TOOLS)/vmmconst.h --noshort-enums

        mv $(MRW_HB_TOOLS)/targeting.bin $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_TARGETING_BIN_FILENAME)
endef

$(eval $(generic-package))
