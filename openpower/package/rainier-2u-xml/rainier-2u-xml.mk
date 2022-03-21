################################################################################
# rainier-2u-xml
#
################################################################################

RAINIER_2U_XML_VERSION ?= $(call qstrip,$(BR2_RAINIER_2U_XML_VERSION))
ifeq ($(BR2_RAINIER_2U_XML_GITHUB_PROJECT),y)
RAINIER_2U_XML_SITE = $(call github,open-power,$(BR2_RAINIER_2U_XML_GITHUB_PROJECT_VALUE),$(RAINIER_2U_XML_VERSION))
else ifeq ($(BR2_RAINIER_2U_XML_CUSTOM_GIT),y)
RAINIER_2U_XML_SITE_METHOD = git
RAINIER_2U_XML_SITE = $(BR2_RAINIER_2U_XML_CUSTOM_GIT_VALUE)
endif

RAINIER_2U_XML_LICENSE = Apache-2.0
RAINIER_2U_XML_LICENSE_FILES = LICENSE
RAINIER_2U_XML_DEPENDENCIES += hostboot-p10

RAINIER_2U_XML_INSTALL_IMAGES = YES
RAINIER_2U_XML_INSTALL_TARGET = YES

RAINIER_2U_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
RAINIER_2U_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
RAINIER_2U_XML_BIOS_SCHEMA_FILE = $(RAINIER_2U_XML_MRW_HB_TOOLS)/bios.xsd
RAINIER_2U_XML_BIOS_CONFIG_FILE = \
    $(call qstrip,$(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_BIOS_FILENAME))
RAINIER_2U_XML_BIOS_METADATA_FILE = \
    $(call qstrip,$(RAINIER_2U_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata.xml)
RAINIER_2U_XML_PETITBOOT_XSLT_FILE = $(RAINIER_2U_XML_MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
RAINIER_2U_XML_PETITBOOT_BIOS_METADATA_FILE = \
    $(call qstrip, \
        $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata_petitboot.xml)
# XXX TODO: Figure out what to do with the bios_metadata.xml. Right now, the last xml
#           package file processed 'wins' and all previously processed xml packages are
#           overriden.
RAINIER_2U_XML_PETITBOOT_BIOS_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

ifeq ($(BR2_RAINIER_2U_XML_OPPOWERVM_ATTRIBUTES),y)
RAINIER_2U_XML_OPPOWERVM_ATTR_XML = $(RAINIER_2U_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
RAINIER_2U_XML_OPPOWERVM_TARGET_XML = $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_RAINIER_2U_XML_TARGET_TYPES_OPENPOWER_XML),y)
RAINIER_2U_XML_TARGET_TYPES_OPENPOWER_XML = $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_openpower.xml
endif
WOF_TOOL = wof_data_xlator.pl
WOF_BIN_OVERRIDE_LIST = wof_bins_for_override.txt

define RAINIER_2U_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(RAINIER_2U_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(RAINIER_2U_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_RAINIER_2U_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_TARGETING_FILENAME))
endef

define RAINIER_2U_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_RAINIER_2U_XML_FILENAME)) \
            $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_RAINIER_2U_XML_FILENAME))
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_RAINIER_2U_XML_BIOS_FILENAME)) \
            $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_RAINIER_2U_XML_BIOS_FILENAME))
	$(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_RAINIER_2U_XML_FILENAME))))
	$(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(RAINIER_2U_XML_MRW_HB_TOOLS) \
        $(RAINIER_2U_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_FILENAME)) \
            -o $(call qstrip,$(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_TARGETING_FILENAME))$

	$(if $(BR2_RAINIER_2U_XML_FILTER_UNWANTED_ATTRIBUTES), $(call RAINIER_2U_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(RAINIER_2U_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_SYSTEM_FILENAME)) \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(RAINIER_2U_XML_OPPOWERVM_ATTR_XML) \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(RAINIER_2U_XML_OPPOWERVM_TARGET_XML) \
            $(RAINIER_2U_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(RAINIER_2U_XML_MRW_SCRATCH)/$(BR2_RAINIER_2U_XML_TARGETING_FILENAME)) \
            > $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_RAINIER_2U_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(RAINIER_2U_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(RAINIER_2U_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_RAINIER_2U_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(RAINIER_2U_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(RAINIER_2U_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(RAINIER_2U_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(RAINIER_2U_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(RAINIER_2U_XML_BIOS_CONFIG_FILE) \
            --bios-schema-file=$(RAINIER_2U_XML_BIOS_SCHEMA_FILE) \
            --bios-output-file=$(RAINIER_2U_XML_BIOS_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(RAINIER_2U_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(RAINIER_2U_XML_PETITBOOT_XSLT_FILE) \
            $(RAINIER_2U_XML_BIOS_METADATA_FILE)

        # Create the wofdata
        if [ -e $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
	$(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_RAINIER_2U_XML_FILENAME))))
	if [ -e $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
	    rm $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
	    cd $(RAINIER_2U_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
            cd $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
            cd $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
	    cd $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(RAINIER_2U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	fi

        # Create the MEMD binary
        if [ -e $(RAINIER_2U_XML_MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(RAINIER_2U_XML_MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip, \
            $(BR2_RAINIER_2U_XML_FILENAME:.xml=.memd_binaries)) ]; then \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/memd_creation.pl \
                -memd_dir $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_RAINIER_2U_XML_FILENAME:.xml=.memd_binaries)) \
                -memd_output $(RAINIER_2U_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_RAINIER_2U_XML_FILENAME:.xml=.memd_output.dat)); \
        fi

endef

define RAINIER_2U_XML_INSTALL_IMAGES_CMDS
        mv $(RAINIER_2U_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(BR2_RAINIER_2U_XML_TARGETING_BIN_FILENAME))
        if [ -e $(RAINIER_2U_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(RAINIER_2U_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(BR2_RAINIER_2U_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(RAINIER_2U_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(RAINIER_2U_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(RAINIER_2U_XML_MRW_HB_TOOLS)/$(BR2_RAINIER_2U_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

define RAINIER_2U_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(RAINIER_2U_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(RAINIER_2U_XML_PETITBOOT_BIOS_INITRAMFS_FILE)
endef

$(eval $(generic-package))
