################################################################################
# blueridge-4u-xml
#
################################################################################

BLUERIDGE_4U_XML_VERSION ?= $(call qstrip,$(BR2_BLUERIDGE_4U_XML_VERSION))
ifeq ($(BR2_BLUERIDGE_4U_XML_GITHUB_PROJECT),y)
BLUERIDGE_4U_XML_SITE = $(call github,open-power,$(BR2_BLUERIDGE_4U_XML_GITHUB_PROJECT_VALUE),$(BLUERIDGE_4U_XML_VERSION))
else ifeq ($(BR2_BLUERIDGE_4U_XML_CUSTOM_GIT),y)
BLUERIDGE_4U_XML_SITE_METHOD = git
BLUERIDGE_4U_XML_SITE = $(BR2_BLUERIDGE_4U_XML_CUSTOM_GIT_VALUE)
endif

BLUERIDGE_4U_XML_LICENSE = Apache-2.0
BLUERIDGE_4U_XML_LICENSE_FILES = LICENSE
BLUERIDGE_4U_XML_DEPENDENCIES += hostboot-p11

BLUERIDGE_4U_XML_INSTALL_IMAGES = YES
BLUERIDGE_4U_XML_INSTALL_TARGET = YES

BLUERIDGE_4U_XML_MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
BLUERIDGE_4U_XML_MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

ifeq ($(BR2_BLUERIDGE_4U_XML_OPPOWERVM_ATTRIBUTES),y)
BLUERIDGE_4U_XML_OPPOWERVM_ATTR_XML = $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/attribute_types_oppowervm.xml
BLUERIDGE_4U_XML_OPPOWERVM_TARGET_XML = $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_BLUERIDGE_4U_XML_TARGET_TYPES_OPENPOWER_XML),y)
BLUERIDGE_4U_XML_TARGET_TYPES_OPENPOWER_XML = $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_openpower.xml
endif
WOF_TOOL = wof_data_xlator.pl
WOF_BIN_OVERRIDE_LIST = wof_bins_for_override.txt

define BLUERIDGE_4U_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip, \
                $(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME))

       cp  $(call qstrip, $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME)).updated \
           $(call qstrip,$(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME))
endef

define BLUERIDGE_4U_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(BR2_BLUERIDGE_4U_XML_FILENAME)) \
            $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip,$(BR2_BLUERIDGE_4U_XML_FILENAME))
        $(eval WOF_SETS_DIR = $$(patsubst %.xml,%.WofSetBins,$(call qstrip,$(BR2_BLUERIDGE_4U_XML_FILENAME))))
        $(eval WOF_SETS_TAR = $(WOF_SETS_DIR).tar.gz)
	if [ -e $(@D)/$(call qstrip,$(WOF_SETS_TAR)) ]; then \
	    $(INSTALL) -m 0644 -D $(@D)/$(call qstrip,$(WOF_SETS_TAR)) \
	        $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip,$(WOF_SETS_TAR)); \
	fi

        # generate the system mrw xml
        perl -I $(BLUERIDGE_4U_XML_MRW_HB_TOOLS) \
        $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/processMrw.pl -x \
            $(call qstrip,$(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_FILENAME)) \
            -o $(call qstrip,$(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME))

	$(if $(BR2_BLUERIDGE_4U_XML_FILTER_UNWANTED_ATTRIBUTES), $(call BLUERIDGE_4U_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/mergexml.sh \
            $(call qstrip,$(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_SYSTEM_FILENAME)) \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/attribute_types.xml \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(BLUERIDGE_4U_XML_OPPOWERVM_ATTR_XML) \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_merged.xml \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/target_types_hb.xml \
            $(BLUERIDGE_4U_XML_OPPOWERVM_TARGET_XML) \
            $(BLUERIDGE_4U_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(call qstrip, \
                $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME)) \
            > $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME))_temporary_hb.hb.xml;

        # creating the targeting binary
        # XXX TODO: xmltohb.pl creates a 'targeting.bin' in the output directory, we want
        #           that file to be unique if we don't want to risk collisions on eventual
        #           parallel builds
        $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(call qstrip, \
                $(BR2_BLUERIDGE_4U_XML_TARGETING_FILENAME))_temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/ \
            --img-output-dir=$(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/vmmconst.h --noshort-enums \

        # Create the wofdata
        if [ -e $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(WOF_TOOL) ]; then \
            chmod +x $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(WOF_TOOL); \
        fi

        # Create WOF override image
	$(eval WOF_OVERRIDE_BIN = $$(patsubst %.xml,%.wofdata,$(call qstrip,$(BR2_BLUERIDGE_4U_XML_FILENAME))))
	if [ -e $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_TAR) ]; then \
	    rm $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN); \
	    cd $(BLUERIDGE_4U_XML_MRW_SCRATCH) && mkdir $(WOF_SETS_DIR); \
            cd $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR) && tar -xzvf $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_TAR); \
            cd $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && ls | grep -i "\.bin" > $(WOF_BIN_OVERRIDE_LIST); \
	    cd $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins && $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(WOF_TOOL) --create $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_OVERRIDE_BIN) --combine $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(WOF_SETS_DIR)/WofSetBins/$(WOF_BIN_OVERRIDE_LIST); \
	else \
	    cd $(BLUERIDGE_4U_XML_MRW_SCRATCH) && dd if=/dev/zero of=$(WOF_OVERRIDE_BIN) bs=4096 count=1; \
	fi

        # Create the MEMD binary
        if [ -e $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip, \
            $(BR2_BLUERIDGE_4U_XML_FILENAME:.xml=.memd_binaries)) ]; then \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/memd_creation.pl \
                -memd_dir $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_BLUERIDGE_4U_XML_FILENAME:.xml=.memd_binaries)) \
                -memd_output $(BLUERIDGE_4U_XML_MRW_SCRATCH)/$(call qstrip, \
                    $(BR2_BLUERIDGE_4U_XML_FILENAME:.xml=.memd_output.dat)); \
        fi

endef

define BLUERIDGE_4U_XML_INSTALL_IMAGES_CMDS
        mv $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/targeting.bin $(call qstrip, \
            $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(BR2_BLUERIDGE_4U_XML_TARGETING_BIN_FILENAME))
        if [ -e $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/targeting.bin.protected \
                $(call qstrip, \
                    $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(BR2_BLUERIDGE_4U_XML_TARGETING_BIN_FILENAME)).protected; \
        fi
        if [ -e $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/targeting.bin.unprotected \
                $(call qstrip, \
                    $(BLUERIDGE_4U_XML_MRW_HB_TOOLS)/$(BR2_BLUERIDGE_4U_XML_TARGETING_BIN_FILENAME)).unprotected; \
        fi
endef

$(eval $(generic-package))
