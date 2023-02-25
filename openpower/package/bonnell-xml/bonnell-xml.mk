################################################################################
# bonnell-xml
#
################################################################################

BONNELL_XML_VERSION ?= $(call qstrip,$(BR2_BONNELL_XML_VERSION))
ifeq ($(BR2_BONNELL_XML_GITHUB_PROJECT),y)
BONNELL_XML_SITE = $(call github,openbmc,$(BR2_BONNELL_XML_GITHUB_PROJECT_VALUE),$(BONNELL_XML_VERSION))
else ifeq ($(BR2_BONNELL_XML_CUSTOM_GIT),y)
BONNELL_XML_SITE_METHOD = git
BONNELL_XML_SITE = $(BR2_BONNELL_XML_CUSTOM_GIT_VALUE)
endif

BONNELL_XML_LICENSE = Apache-2.0
BONNELL_XML_LICENSE_FILES = LICENSE
BONNELL_XML_DEPENDENCIES += hostboot-p10

BONNELL_XML_INSTALL_IMAGES = YES
BONNELL_XML_INSTALL_TARGET = YES

BONNELL_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
BONNELL_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
BONNELL_XML_BIOS_SCHEMA_FILE = $(BONNELL_XML_MRW_HB_TOOLS)/bios.xsd
BONNELL_XML_BIOS_CONFIG_FILE = \
    $(call qstrip,$(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_BIOS_FILENAME))
BONNELL_XML_BIOS_METADATA_FILE = \
    $(call qstrip,$(BONNELL_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata.xml)
BONNELL_XML_PETITBOOT_XSLT_FILE = $(BONNELL_XML_MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
BONNELL_XML_PETITBOOT_BIOS_METADATA_FILE = \
    $(call qstrip, \
        $(BONNELL_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata_petitboot.xml)
# XXX TODO: Figure out what to do with the bios_metadata.xml. Right now, the last xml
#           package file processed 'wins' and all previously processed xml packages are
#           overriden.
BONNELL_XML_PETITBOOT_BIOS_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

ifeq ($(BR2_BONNELL_XML_OPPOWERVM_ATTRIBUTES),y)
BONNELL_XML_OPPOWERVM_ATTR_XML = $(BONNELL_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
BONNELL_XML_OPPOWERVM_TARGET_XML = $(BONNELL_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_BONNELL_XML_TARGET_TYPES_OPENPOWER_XML),y)
BONNELL_XML_TARGET_TYPES_OPENPOWER_XML = $(BONNELL_XML_MRW_HB_TOOLS)/target_types_openpower.xml
endif
WOF_TOOL = wof_data_xlator.pl
WOF_BIN_OVERRIDE_LIST = wof_bins_for_override.txt

# Defines for SPD file creation
NEXT_EC=10
IMAGE_TOKEN=--ecImg_10

define build_ecImgs
    $(eval SPD_FILES_TOKENED += $$(addprefix $(2) , $(1)))
    $(eval NEXT_EC=$(shell echo $$(($(NEXT_EC)+10))))
    $(eval IMAGE_TOKEN = --ecImg_$(NEXT_EC))
endef

define BONNELL_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(BONNELL_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(BONNELL_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(BONNELL_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(BONNELL_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(BONNELL_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(BONNELL_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_BONNELL_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_TARGETING_FILENAME))
endef

define BONNELL_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_BONNELL_XML_FILENAME)) \
            $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_BONNELL_XML_FILENAME))
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_BONNELL_XML_BIOS_FILENAME)) \
            $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_BONNELL_XML_BIOS_FILENAME))
        $(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_BONNELL_XML_FILENAME))))
        $(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(BONNELL_XML_MRW_HB_TOOLS) \
        $(BONNELL_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_FILENAME)) \
            -o $(call qstrip,$(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_TARGETING_FILENAME))

	$(if $(BR2_BONNELL_XML_FILTER_UNWANTED_ATTRIBUTES), $(call BONNELL_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(BONNELL_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_SYSTEM_FILENAME)) \
            $(BONNELL_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(BONNELL_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(BONNELL_XML_OPPOWERVM_ATTR_XML) \
            $(BONNELL_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(BONNELL_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(BONNELL_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(BONNELL_XML_OPPOWERVM_TARGET_XML) \
            $(BONNELL_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(BONNELL_XML_MRW_SCRATCH)/$(BR2_BONNELL_XML_TARGETING_FILENAME)) \
            > $(BONNELL_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BONNELL_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(BONNELL_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(BONNELL_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BONNELL_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(BONNELL_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(BONNELL_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(BONNELL_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(BONNELL_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(BONNELL_XML_BIOS_CONFIG_FILE) \
            --bios-schema-file=$(BONNELL_XML_BIOS_SCHEMA_FILE) \
            --bios-output-file=$(BONNELL_XML_BIOS_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(BONNELL_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(BONNELL_XML_PETITBOOT_XSLT_FILE) \
            $(BONNELL_XML_BIOS_METADATA_FILE)

        # Create the wofdata
        if [ -e $(BONNELL_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(BONNELL_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
	$(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_BONNELL_XML_FILENAME))))
	if [ -e $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
	    rm $(BONNELL_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
	    cd $(BONNELL_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
            cd $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
            cd $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
	    cd $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(BONNELL_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(BONNELL_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(BONNELL_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	else \
	    cd $(BONNELL_XML_MRW_SCRATCH) && dd if=/dev/zero of=$(WOF_OVERRIDE_BIN) bs=4096 count=1; \
	fi

        # Create SPD image, if necessary
        $(eval PSPD_BIN = $$(patsubst %.xml,%.PSPD.bin,$(call qstrip,$(BR2_BONNELL_XML_FILENAME))))
        $(eval SPD_IMAGE_FILES = $$(wildcard $(BONNELL_XML_MRW_SCRATCH)/*.pspddata*))

        # Cleanup old PSPD.bin
        if [ -e "$(BONNELL_XML_MRW_SCRATCH)/$(PSPD_BIN)" ]; then \
            rm $(BONNELL_XML_MRW_SCRATCH)/$(PSPD_BIN); \
        fi

        $(foreach spd_image_file, $(SPD_IMAGE_FILES), \
            $(call build_ecImgs,$(spd_image_file),$(IMAGE_TOKEN)))

        # SPD_FILES_TOKENED is what is used as input for the --ecImg_'s to buildSPDImages.pl
        #
        # If SPD_FILES_TOKENED is empty we get zero SPD Images built (tocCount=0)
        #
        # SPD_ARG_ITEMS (will only output debug info if buildSPDImages.pl will result in tocCount more than zero)
        $(foreach spd_arg, $(SPD_FILES_TOKENED), echo SPD_ARG_ITEMS $(spd_arg);)

        # If we have SPD images the PSPD.bin will be built containing the data, otherwise we get PSPD.bin with all FF's
        if [ -e "$(BONNELL_XML_MRW_HB_TOOLS)/buildSPDImages.pl" ] && [ -n "$(SPD_IMAGE_FILES)" ]; then \
            chmod +x $(BONNELL_XML_MRW_HB_TOOLS)/buildSPDImages.pl; \
            echo "*** RUNNING buildSPDImages.pl ***";\
            $(BONNELL_XML_MRW_HB_TOOLS)/buildSPDImages.pl --spdOutBin $(BONNELL_XML_MRW_SCRATCH)/$(PSPD_BIN) $(SPD_FILES_TOKENED); \
        fi

        # Create the MEMD binary
        if [ -e $(BONNELL_XML_MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(BONNELL_XML_MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip, \
            $(BR2_BONNELL_XML_FILENAME:.xml=.memd_binaries)) ]; then \
            $(BONNELL_XML_MRW_HB_TOOLS)/memd_creation.pl \
                -memd_dir $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_BONNELL_XML_FILENAME:.xml=.memd_binaries)) \
                -memd_output $(BONNELL_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_BONNELL_XML_FILENAME:.xml=.memd_output.dat)); \
        fi

endef

define BONNELL_XML_INSTALL_IMAGES_CMDS
        mv $(BONNELL_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(BONNELL_XML_MRW_HB_TOOLS)/$(BR2_BONNELL_XML_TARGETING_BIN_FILENAME))
        if [ -e $(BONNELL_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(BONNELL_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(BONNELL_XML_MRW_HB_TOOLS)/$(BR2_BONNELL_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(BONNELL_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(BONNELL_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(BONNELL_XML_MRW_HB_TOOLS)/$(BR2_BONNELL_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

define BONNELL_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(BONNELL_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(BONNELL_XML_PETITBOOT_BIOS_INITRAMFS_FILE)
endef

$(eval $(generic-package))
