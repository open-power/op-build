################################################################################
# fuji-xml
#
################################################################################

FUJI_XML_VERSION ?= $(call qstrip,$(BR2_FUJI_XML_VERSION))
ifeq ($(BR2_FUJI_XML_GITHUB_PROJECT),y)
FUJI_XML_SITE = $(call github,open-power,$(BR2_FUJI_XML_GITHUB_PROJECT_VALUE),$(FUJI_XML_VERSION))
else ifeq ($(BR2_FUJI_XML_CUSTOM_GIT),y)
FUJI_XML_SITE_METHOD = git
FUJI_XML_SITE = $(BR2_FUJI_XML_CUSTOM_GIT_VALUE)
endif

FUJI_XML_LICENSE = Apache-2.0
FUJI_XML_LICENSE_FILES = LICENSE
FUJI_XML_DEPENDENCIES += hostboot-p11

FUJI_XML_INSTALL_IMAGES = YES
FUJI_XML_INSTALL_TARGET = YES

FUJI_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
FUJI_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
FUJI_XML_BIOS_SCHEMA_FILE = $(FUJI_XML_MRW_HB_TOOLS)/bios.xsd
FUJI_XML_BIOS_CONFIG_FILE = \
    $(call qstrip,$(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_BIOS_FILENAME))
FUJI_XML_BIOS_METADATA_FILE = \
    $(call qstrip,$(FUJI_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata.xml)
FUJI_XML_PETITBOOT_XSLT_FILE = $(FUJI_XML_MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
FUJI_XML_PETITBOOT_BIOS_METADATA_FILE = \
    $(call qstrip, \
        $(FUJI_XML_MRW_HB_TOOLS)/$(BR2_OPENPOWER_P10_CONFIG_NAME)_bios_metadata_petitboot.xml)
# XXX TODO: Figure out what to do with the bios_metadata.xml. Right now, the last xml
#           package file processed 'wins' and all previously processed xml packages are
#           overriden.
FUJI_XML_PETITBOOT_BIOS_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

ifeq ($(BR2_FUJI_XML_OPPOWERVM_ATTRIBUTES),y)
FUJI_XML_OPPOWERVM_ATTR_XML = $(FUJI_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
FUJI_XML_OPPOWERVM_TARGET_XML = $(FUJI_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_FUJI_XML_TARGET_TYPES_OPENPOWER_XML),y)
FUJI_XML_TARGET_TYPES_OPENPOWER_XML = $(FUJI_XML_MRW_HB_TOOLS)/target_types_openpower.xml
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

define FUJI_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(FUJI_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(FUJI_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(FUJI_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(FUJI_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(FUJI_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(FUJI_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(FUJI_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_FUJI_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_TARGETING_FILENAME))
endef

define FUJI_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_FUJI_XML_FILENAME)) \
            $(FUJI_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_FUJI_XML_FILENAME))
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_FUJI_XML_BIOS_FILENAME)) \
            $(FUJI_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_FUJI_XML_BIOS_FILENAME))
        $(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_FUJI_XML_FILENAME))))
        $(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(FUJI_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(FUJI_XML_MRW_HB_TOOLS) \
        $(FUJI_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_FILENAME)) \
            -o $(call qstrip,$(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_TARGETING_FILENAME))

	$(if $(BR2_FUJI_XML_FILTER_UNWANTED_ATTRIBUTES), $(call FUJI_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(FUJI_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_SYSTEM_FILENAME)) \
            $(FUJI_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(FUJI_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(FUJI_XML_OPPOWERVM_ATTR_XML) \
            $(FUJI_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(FUJI_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(FUJI_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(FUJI_XML_OPPOWERVM_TARGET_XML) \
            $(FUJI_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(FUJI_XML_MRW_SCRATCH)/$(BR2_FUJI_XML_TARGETING_FILENAME)) \
            > $(FUJI_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_FUJI_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(FUJI_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(FUJI_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_FUJI_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(FUJI_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(FUJI_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(FUJI_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(FUJI_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(FUJI_XML_BIOS_CONFIG_FILE) \
            --bios-schema-file=$(FUJI_XML_BIOS_SCHEMA_FILE) \
            --bios-output-file=$(FUJI_XML_BIOS_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(FUJI_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(FUJI_XML_PETITBOOT_XSLT_FILE) \
            $(FUJI_XML_BIOS_METADATA_FILE)

        # Create the wofdata
        if [ -e $(FUJI_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(FUJI_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
	$(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_FUJI_XML_FILENAME))))
	if [ -e $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
	    rm $(FUJI_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
	    cd $(FUJI_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
            cd $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
            cd $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
	    cd $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(FUJI_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(FUJI_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(FUJI_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	else \
	    cd $(FUJI_XML_MRW_SCRATCH) && dd if=/dev/zero of=$(WOF_OVERRIDE_BIN) bs=4096 count=1; \
	fi

        # Create SPD image, if necessary
        $(eval PSPD_BIN = $$(patsubst %.xml,%.PSPD.bin,$(call qstrip,$(BR2_FUJI_XML_FILENAME))))
        $(eval SPD_IMAGE_FILES = $$(wildcard $(FUJI_XML_MRW_SCRATCH)/*.pspddata*))

        # Cleanup old PSPD.bin
        if [ -e "$(FUJI_XML_MRW_SCRATCH)/$(PSPD_BIN)" ]; then \
            rm $(FUJI_XML_MRW_SCRATCH)/$(PSPD_BIN); \
        fi

        $(foreach spd_image_file, $(SPD_IMAGE_FILES), \
            $(call build_spdImgs,$(spd_image_file),$(IMAGE_TOKEN)))

        # SPD_FILES_TOKENED is what is used as input for the --spdImg_'s to buildSPDImages.pl
        #
        # If SPD_FILES_TOKENED is empty we get zero SPD Images built (tocCount=0)
        #
        # SPD_ARG_ITEMS (will only output debug info if buildSPDImages.pl will result in tocCount more than zero)
        $(foreach spd_arg, $(SPD_FILES_TOKENED), echo SPD_ARG_ITEMS $(spd_arg);)

        # If we have SPD images the PSPD.bin will be built containing the data, otherwise we get PSPD.bin with all FF's
        if [ -e "$(FUJI_XML_MRW_HB_TOOLS)/buildSPDImages.pl" ] && [ -n "$(SPD_IMAGE_FILES)" ]; then \
            chmod +x $(FUJI_XML_MRW_HB_TOOLS)/buildSPDImages.pl; \
            echo "*** RUNNING buildSPDImages.pl ***";\
            $(FUJI_XML_MRW_HB_TOOLS)/buildSPDImages.pl --spdOutBin $(FUJI_XML_MRW_SCRATCH)/$(PSPD_BIN) $(SPD_FILES_TOKENED); \
        fi

        # Create the MEMD binary
        if [ -e $(FUJI_XML_MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(FUJI_XML_MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(FUJI_XML_MRW_SCRATCH)/$(call qstrip, \
            $(BR2_FUJI_XML_FILENAME:.xml=.memd_binaries)) ]; then \
            $(FUJI_XML_MRW_HB_TOOLS)/memd_creation.pl \
                -memd_dir $(FUJI_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_FUJI_XML_FILENAME:.xml=.memd_binaries)) \
                -memd_output $(FUJI_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_FUJI_XML_FILENAME:.xml=.memd_output.dat)); \
        fi

endef

define FUJI_XML_INSTALL_IMAGES_CMDS
        mv $(FUJI_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(FUJI_XML_MRW_HB_TOOLS)/$(BR2_FUJI_XML_TARGETING_BIN_FILENAME))
        if [ -e $(FUJI_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(FUJI_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(FUJI_XML_MRW_HB_TOOLS)/$(BR2_FUJI_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(FUJI_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(FUJI_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(FUJI_XML_MRW_HB_TOOLS)/$(BR2_FUJI_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

define FUJI_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(FUJI_XML_PETITBOOT_BIOS_METADATA_FILE) \
            $(FUJI_XML_PETITBOOT_BIOS_INITRAMFS_FILE)
endef

$(eval $(generic-package))
