################################################################################
# everest-xml
#
################################################################################

EVEREST_XML_VERSION ?= $(call qstrip,$(BR2_EVEREST_XML_VERSION))
ifeq ($(BR2_EVEREST_XML_GITHUB_PROJECT),y)
EVEREST_XML_SITE = $(call github,open-power,$(BR2_EVEREST_XML_GITHUB_PROJECT_VALUE),$(EVEREST_XML_VERSION))
else ifeq ($(BR2_EVEREST_XML_CUSTOM_GIT),y)
EVEREST_XML_SITE_METHOD = git
EVEREST_XML_SITE = $(BR2_EVEREST_XML_CUSTOM_GIT_VALUE)
endif

EVEREST_XML_LICENSE = Apache-2.0
EVEREST_XML_LICENSE_FILES = LICENSE
EVEREST_XML_DEPENDENCIES += hostboot-p10

EVEREST_XML_INSTALL_IMAGES = YES
EVEREST_XML_INSTALL_TARGET = YES

EVEREST_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
EVEREST_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
EVEREST_XML_BIOS_SCHEMA_FILE = $(EVEREST_XML_MRW_HB_TOOLS)/bios.xsd
EVEREST_XML_BIOS_CONFIG_FILE = \
    $(call qstrip,$(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_BIOS_FILENAME))
EVEREST_XML_BIOS_METADATA_FILE = \
    $(call qstrip,$(EVEREST_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata.xml)
EVEREST_XML_PETITBOOT_XSLT_FILE = $(EVEREST_XML_MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
EVEREST_XML_PETITBOOT_BIOS_METADATA_FILE = \
    $(call qstrip, \
        $(EVEREST_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata_petitboot.xml)
# XXX TODO: Figure out what to do with the bios_metadata.xml. Right now, the last xml
#           package file processed 'wins' and all previously processed xml packages are
#           overriden.
EVEREST_XML_PETITBOOT_BIOS_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

ifeq ($(BR2_EVEREST_XML_OPPOWERVM_ATTRIBUTES),y)
EVEREST_XML_OPPOWERVM_ATTR_XML = $(EVEREST_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
EVEREST_XML_OPPOWERVM_TARGET_XML = $(EVEREST_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_EVEREST_XML_TARGET_TYPES_OPENPOWER_XML),y)
EVEREST_XML_TARGET_TYPES_OPENPOWER_XML = $(EVEREST_XML_MRW_HB_TOOLS)/target_types_openpower.xml
endif
WOF_TOOL = wof_data_xlator.pl
WOF_BIN_OVERRIDE_LIST = wof_bins_for_override.txt

define EVEREST_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(EVEREST_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(EVEREST_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(EVEREST_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(EVEREST_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(EVEREST_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(EVEREST_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_EVEREST_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_TARGETING_FILENAME))
endef

define EVEREST_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_EVEREST_XML_FILENAME)) \
            $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_EVEREST_XML_FILENAME))
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_EVEREST_XML_BIOS_FILENAME)) \
            $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_EVEREST_XML_BIOS_FILENAME))
        $(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_EVEREST_XML_FILENAME))))
        $(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(EVEREST_XML_MRW_HB_TOOLS) \
        $(EVEREST_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_FILENAME)) \
            -o $(call qstrip,$(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_TARGETING_FILENAME))

	$(if $(BR2_EVEREST_XML_FILTER_UNWANTED_ATTRIBUTES), $(call EVEREST_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(EVEREST_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_SYSTEM_FILENAME)) \
            $(EVEREST_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(EVEREST_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(EVEREST_XML_OPPOWERVM_ATTR_XML) \
            $(EVEREST_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(EVEREST_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(EVEREST_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(EVEREST_XML_OPPOWERVM_TARGET_XML) \
            $(EVEREST_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(EVEREST_XML_MRW_SCRATCH)/$(BR2_EVEREST_XML_TARGETING_FILENAME)) \
            > $(EVEREST_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_EVEREST_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(EVEREST_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(EVEREST_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_EVEREST_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(EVEREST_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(EVEREST_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(EVEREST_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(EVEREST_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(EVEREST_XML_BIOS_CONFIG_FILE) \
            --bios-schema-file=$(EVEREST_XML_BIOS_SCHEMA_FILE) \
            --bios-output-file=$(EVEREST_XML_BIOS_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(EVEREST_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(EVEREST_XML_PETITBOOT_XSLT_FILE) \
            $(EVEREST_XML_BIOS_METADATA_FILE)

        # Create the wofdata
        if [ -e $(EVEREST_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(EVEREST_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
	$(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_EVEREST_XML_FILENAME))))
	if [ -e $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
	    rm $(EVEREST_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
	    cd $(EVEREST_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
            cd $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
            cd $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
	    cd $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(EVEREST_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(EVEREST_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(EVEREST_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	else \
	    cd $(EVEREST_XML_MRW_SCRATCH) && dd if=/dev/zero of=$(WOF_OVERRIDE_BIN) bs=4096 count=1; \
	fi

        # Create the MEMD binary
        if [ -e $(EVEREST_XML_MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(EVEREST_XML_MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip, \
            $(BR2_EVEREST_XML_FILENAME:.xml=.memd_binaries)) ]; then \
            $(EVEREST_XML_MRW_HB_TOOLS)/memd_creation.pl \
                -memd_dir $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_EVEREST_XML_FILENAME:.xml=.memd_binaries)) \
                -memd_output $(EVEREST_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_EVEREST_XML_FILENAME:.xml=.memd_output.dat)); \
        fi

endef

define EVEREST_XML_INSTALL_IMAGES_CMDS
        mv $(EVEREST_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(EVEREST_XML_MRW_HB_TOOLS)/$(BR2_EVEREST_XML_TARGETING_BIN_FILENAME))
        if [ -e $(EVEREST_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(EVEREST_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(EVEREST_XML_MRW_HB_TOOLS)/$(BR2_EVEREST_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(EVEREST_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(EVEREST_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(EVEREST_XML_MRW_HB_TOOLS)/$(BR2_EVEREST_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

define EVEREST_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(EVEREST_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(EVEREST_XML_PETITBOOT_BIOS_INITRAMFS_FILE)
endef

$(eval $(generic-package))
