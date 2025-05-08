################################################################################
# balcones-xml
#
################################################################################

BALCONES_XML_VERSION ?= $(call qstrip,$(BR2_BALCONES_XML_VERSION))
ifeq ($(BR2_BALCONES_XML_GITHUB_PROJECT),y)
BALCONES_XML_SITE = $(call github,open-power,$(BR2_BALCONES_XML_GITHUB_PROJECT_VALUE),$(BALCONES_XML_VERSION))
else ifeq ($(BR2_BALCONES_XML_CUSTOM_GIT),y)
BALCONES_XML_SITE_METHOD = git
BALCONES_XML_SITE = $(BR2_BALCONES_XML_CUSTOM_GIT_VALUE)
endif

BALCONES_XML_LICENSE = Apache-2.0
BALCONES_XML_LICENSE_FILES = LICENSE
BALCONES_XML_DEPENDENCIES += hostboot-p11

BALCONES_XML_INSTALL_IMAGES = YES
BALCONES_XML_INSTALL_TARGET = YES

BALCONES_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
BALCONES_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
BALCONES_XML_BIOS_SCHEMA_FILE = $(BALCONES_XML_MRW_HB_TOOLS)/bios.xsd
BALCONES_XML_BIOS_CONFIG_FILE = \
    $(call qstrip,$(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_BIOS_FILENAME))
BALCONES_XML_BIOS_METADATA_FILE = \
    $(call qstrip,$(BALCONES_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P11_CONFIG_NAME)_bios_metadata.xml)
BALCONES_XML_PETITBOOT_XSLT_FILE = $(BALCONES_XML_MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
BALCONES_XML_PETITBOOT_BIOS_METADATA_FILE = \
    $(call qstrip, \
        $(BALCONES_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P11_CONFIG_NAME)_bios_metadata_petitboot.xml)
# XXX TODO: Figure out what to do with the bios_metadata.xml. Right now, the last xml
#           package file processed 'wins' and all previously processed xml packages are
#           overriden.
BALCONES_XML_PETITBOOT_BIOS_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

ifeq ($(BR2_BALCONES_XML_OPPOWERVM_ATTRIBUTES),y)
BALCONES_XML_OPPOWERVM_ATTR_XML = $(BALCONES_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
BALCONES_XML_OPPOWERVM_TARGET_XML = $(BALCONES_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_BALCONES_XML_TARGET_TYPES_OPENPOWER_XML),y)
BALCONES_XML_TARGET_TYPES_OPENPOWER_XML = $(BALCONES_XML_MRW_HB_TOOLS)/target_types_openpower.xml
endif
WOF_TOOL = wof_data_xlator.pl
WOF_BIN_OVERRIDE_LIST = wof_bins_for_override.txt

# Defines for SPD file creation
NEXT_INDEX=1
IMAGE_TOKEN=--spdImg_1

define build_spdImgs
    $(eval SPD_FILES_TOKENED += $$(addprefix $(2) , $(1)))
    $(eval NEXT_INDEX=$(shell echo $$(($(NEXT_INDEX)+1))))
    $(eval IMAGE_TOKEN = --spdImg_$(NEXT_INDEX))
endef

define BALCONES_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(BALCONES_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(BALCONES_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(BALCONES_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(BALCONES_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(BALCONES_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(BALCONES_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(BALCONES_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_BALCONES_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_TARGETING_FILENAME))
endef

define BALCONES_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_BALCONES_XML_FILENAME)) \
            $(BALCONES_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_BALCONES_XML_FILENAME))
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_BALCONES_XML_BIOS_FILENAME)) \
            $(BALCONES_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_BALCONES_XML_BIOS_FILENAME))
        $(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_BALCONES_XML_FILENAME))))
        $(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(BALCONES_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(BALCONES_XML_MRW_HB_TOOLS) \
        $(BALCONES_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_FILENAME)) \
            -o $(call qstrip,$(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_TARGETING_FILENAME))

	$(if $(BR2_BALCONES_XML_FILTER_UNWANTED_ATTRIBUTES), $(call BALCONES_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(BALCONES_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_SYSTEM_FILENAME)) \
            $(BALCONES_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(BALCONES_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(BALCONES_XML_OPPOWERVM_ATTR_XML) \
            $(BALCONES_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(BALCONES_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(BALCONES_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(BALCONES_XML_OPPOWERVM_TARGET_XML) \
            $(BALCONES_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(BALCONES_XML_MRW_SCRATCH)/$(BR2_BALCONES_XML_TARGETING_FILENAME)) \
            > $(BALCONES_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BALCONES_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(BALCONES_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(BALCONES_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BALCONES_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(BALCONES_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(BALCONES_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(BALCONES_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(BALCONES_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(BALCONES_XML_BIOS_CONFIG_FILE) \
            --bios-schema-file=$(BALCONES_XML_BIOS_SCHEMA_FILE) \
            --bios-output-file=$(BALCONES_XML_BIOS_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(BALCONES_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(BALCONES_XML_PETITBOOT_XSLT_FILE) \
            $(BALCONES_XML_BIOS_METADATA_FILE)

        # Create the wofdata
        if [ -e $(BALCONES_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(BALCONES_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
        $(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_BALCONES_XML_FILENAME))))
        if [ -e $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
           rm $(BALCONES_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
           cd $(BALCONES_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
           cd $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
           cd $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
           cd $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(BALCONES_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(BALCONES_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(BALCONES_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	       else \
           cd $(BALCONES_XML_MRW_SCRATCH) && dd if=/dev/zero of=$(WOF_OVERRIDE_BIN) bs=4096 count=1; \
        fi

endef

define BALCONES_XML_INSTALL_IMAGES_CMDS
        mv $(BALCONES_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(BALCONES_XML_MRW_HB_TOOLS)/$(BR2_BALCONES_XML_TARGETING_BIN_FILENAME))
        if [ -e $(BALCONES_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(BALCONES_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(BALCONES_XML_MRW_HB_TOOLS)/$(BR2_BALCONES_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(BALCONES_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(BALCONES_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(BALCONES_XML_MRW_HB_TOOLS)/$(BR2_BALCONES_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

define BALCONES_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(BALCONES_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(BALCONES_XML_PETITBOOT_BIOS_INITRAMFS_FILE)
endef

$(eval $(generic-package))
