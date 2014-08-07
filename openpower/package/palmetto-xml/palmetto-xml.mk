################################################################################
#
# palmetto_xml
#
################################################################################

PALMETTO_XML_VERSION = 7667c42a1a6097030564dcf06879b7ae66656e9a
PALMETTO_XML_SITE = $(call github,open-power,palmetto-xml,$(PALMETTO_XML_VERSION))

PALMETTO_XML_LICENSE = Apache-2.0
PALMETTO_XML_DEPENDENCIES = hostboot-install-images openpower-mrw-install-images common-p8-xml-install-images

PALMETTO_XML_INSTALL_IMAGES = YES
PALMETTO_XML_INSTALL_TARGET = NO

MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
MRW_INSTALL_DIRECTORY=$(STAGING_DIR)/preprocessed_mrw
MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

PALMETTO_XML_ENV_VARS= \
    SCHEMA_FILE=$(MRW_SCRATCH)/schema/mrw.xsd \
    PARSER_PATH=$(STAGING_DIR)/usr/bin \
    XSL_PATH=$(MRW_SCRATCH)/xslt \
    OUTPUT_PATH=$(MRW_INSTALL_DIRECTORY)

define PALMETTO_XML_BUILD_CMDS
        # copy the palmetto xml where the common lives
        bash -c 'mkdir -p $(MRW_SCRATCH) && cp -r $(@D)/* $(MRW_SCRATCH)'
        mkdir -p $(MRW_INSTALL_DIRECTORY)

        # run the mrw parsers
        $(PALMETTO_XML_ENV_VARS) bash -c 'cd $(MRW_SCRATCH) && $(MAKE) palmetto'

        # generate the system mrm xml
        $(MRW_HB_TOOLS)/genHwsvMrwXml.pl \
            --system=$(BR2_OPENPOWER_CONFIG_NAME) \
            --mrwdir=$(MRW_INSTALL_DIRECTORY) \
            --build=hb > $(MRW_INSTALL_DIRECTORY)/$(BR2_PALMETTO_MRW_XML_FILENAME)

endef

define PALMETTO_XML_INSTALL_IMAGES_CMDS

        # merge in any system specific attributes, hostboot attributes
        $(MRW_HB_TOOLS)/mergexml.sh $(@D)/$(BR2_PALMETTO_SYSTEM_XML_FILENAME) \
            $(MRW_HB_TOOLS)/attribute_types.xml \
            $(MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(MRW_HB_TOOLS)/target_types_merged.xml \
            $(MRW_HB_TOOLS)/target_types_hb.xml \
            $(MRW_INSTALL_DIRECTORY)/$(BR2_PALMETTO_MRW_XML_FILENAME) > $(MRW_HB_TOOLS)/temporary_hb.hb.xml;

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
