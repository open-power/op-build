################################################################################
# machine_xml
#
################################################################################

MACHINE_XML_VERSION ?= $(call qstrip,$(BR2_OPENPOWER_MACHINE_XML_VERSION))
ifeq ($(BR2_OPENPOWER_MACHINE_XML_GITHUB_PROJECT),y)
MACHINE_XML_SITE = $(call github,open-power,$(BR2_OPENPOWER_MACHINE_XML_GITHUB_PROJECT_VALUE),$(MACHINE_XML_VERSION))
else ifeq ($(BR2_OPENPOWER_MACHINE_XML_CUSTOM_GIT),y)
MACHINE_XML_SITE_METHOD = git
MACHINE_XML_SITE = $(BR2_OPENPOWER_MACHINE_XML_CUSTOM_GIT_VALUE)
endif

MACHINE_XML_LICENSE = Apache-2.0
MACHINE_XML_LICENSE_FILES = LICENSE
MACHINE_XML_DEPENDENCIES =

ifeq ($(BR2_OPENPOWER_POWER9),y)
MACHINE_XML_DEPENDENCIES += hostboot
endif
ifeq ($(BR2_OPENPOWER_POWER8),y)
MACHINE_XML_DEPENDENCIES += hostboot-p8 openpower-mrw common-p8-xml
endif

MACHINE_XML_INSTALL_IMAGES = YES
MACHINE_XML_INSTALL_TARGET = YES

MRW_SCRATCH=$(STAGING_DIR)/openpower_mrw_scratch
MRW_HB_TOOLS=$(STAGING_DIR)/hostboot_build_images

# Defines for BIOS metadata creation
BIOS_SCHEMA_FILE = $(MRW_HB_TOOLS)/bios.xsd
OPENPOWER_BIOS_XML_CONFIG_FILE = $(MRW_SCRATCH)/$(BR2_OPENPOWER_BIOS_XML_FILENAME)
BIOS_XML_METADATA_FILE = \
    $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_CONFIG_NAME)_bios_metadata.xml
PETITBOOT_XSLT_FILE = $(MRW_HB_TOOLS)/bios_metadata_petitboot.xslt
PETITBOOT_BIOS_XML_METADATA_FILE = \
    $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_CONFIG_NAME)_bios_metadata_petitboot.xml
PETITBOOT_BIOS_XML_METADATA_INITRAMFS_FILE = \
    $(TARGET_DIR)/usr/share/bios_metadata.xml

WOFDATA_FILE = `ls $(MRW_SCRATCH)/wofdata`

ifeq ($(BR2_OPENPOWER_MACHINE_XML_OPPOWERVM_ATTRIBUTES),y)
MACHINE_XML_OPPOWERVM_ATTR_XML = $(MRW_HB_TOOLS)/attribute_types_oppowervm.xml
MACHINE_XML_OPPOWERVM_TARGET_XML = $(MRW_HB_TOOLS)/target_types_oppowervm.xml
endif
ifeq ($(BR2_OPENPOWER_MACHINE_XML_TARGET_TYPES_OPENPOWER_XML),y)
MACHINE_XML_TARGET_TYPES_OPENPOWER_XML = $(MRW_HB_TOOLS)/target_types_openpower.xml
endif

define MACHINE_XML_FILTER_UNWANTED_ATTRIBUTES
       chmod +x $(MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl

       $(MRW_HB_TOOLS)/filter_out_unwanted_attributes.pl \
            --tgt-xml $(MRW_HB_TOOLS)/target_types_merged.xml \
            --tgt-xml $(MRW_HB_TOOLS)/target_types_hb.xml \
            --tgt-xml $(MRW_HB_TOOLS)/target_types_oppowervm.xml \
            --tgt-xml $(MRW_HB_TOOLS)/target_types_openpower.xml \
            --mrw-xml $(MRW_SCRATCH)/$(BR2_OPENPOWER_MRW_XML_FILENAME)

       cp  $(MRW_SCRATCH)/$(BR2_OPENPOWER_MRW_XML_FILENAME).updated  $(MRW_SCRATCH)/$(BR2_OPENPOWER_MRW_XML_FILENAME)
endef

define MACHINE_XML_BUILD_CMDS
        # copy the machine xml where the common lives
        bash -c 'mkdir -p $(MRW_SCRATCH) && cp -r $(@D)/* $(MRW_SCRATCH)'

        # generate the system mrw xml
        perl -I $(MRW_HB_TOOLS) \
        $(MRW_HB_TOOLS)/processMrw.pl -x $(MRW_SCRATCH)/$(BR2_OPENPOWER_MACHINE_XML_FILENAME)

	$(if $(BR2_OPENPOWER_MACHINE_XML_FILTER_UNWANTED_ATTRIBUTES), $(call MACHINE_XML_FILTER_UNWANTED_ATTRIBUTES))

        # merge in any system specific attributes, hostboot attributes
        $(MRW_HB_TOOLS)/mergexml.sh $(MRW_SCRATCH)/$(BR2_OPENPOWER_SYSTEM_XML_FILENAME) \
            $(MRW_HB_TOOLS)/attribute_types.xml \
            $(MRW_HB_TOOLS)/attribute_types_hb.xml \
            $(MACHINE_XML_OPPOWERVM_ATTR_XML) \
            $(MRW_HB_TOOLS)/attribute_types_openpower.xml \
            $(MRW_HB_TOOLS)/target_types_merged.xml \
            $(MRW_HB_TOOLS)/target_types_hb.xml \
            $(MACHINE_XML_OPPOWERVM_TARGET_XML) \
            $(MACHINE_XML_TARGET_TYPES_OPENPOWER_XML) \
            $(MRW_SCRATCH)/$(BR2_OPENPOWER_MRW_XML_FILENAME) > $(MRW_HB_TOOLS)/temporary_hb.hb.xml;

        # creating the targeting binary
        $(MRW_HB_TOOLS)/xmltohb.pl  \
            --hb-xml-file=$(MRW_HB_TOOLS)/temporary_hb.hb.xml \
            --fapi-attributes-xml-file=$(MRW_HB_TOOLS)/fapiattrs.xml \
            --src-output-dir=$(MRW_HB_TOOLS)/ \
            --img-output-dir=$(MRW_HB_TOOLS)/ \
            --vmm-consts-file=$(MRW_HB_TOOLS)/vmmconst.h --noshort-enums \
            --bios-xml-file=$(OPENPOWER_BIOS_XML_CONFIG_FILE) \
            --bios-schema-file=$(BIOS_SCHEMA_FILE) \
            --bios-output-file=$(BIOS_XML_METADATA_FILE)

        # Transform BIOS XML into Petitboot specific BIOS XML via the schema
        xsltproc -o \
            $(PETITBOOT_BIOS_XML_METADATA_FILE) \
            $(PETITBOOT_XSLT_FILE) \
            $(BIOS_XML_METADATA_FILE)

        # Create the wofdata
        if [ -e $(MRW_HB_TOOLS)/wof-tables-img ]; then \
            chmod +x $(MRW_HB_TOOLS)/wof-tables-img; \
        fi

        if [ -d $(MRW_SCRATCH)/wofdata ]; then \
            $(MRW_HB_TOOLS)/wof-tables-img --create $(MRW_SCRATCH)/wof_output $(MRW_SCRATCH)/wofdata; \
        fi

        # Create the MEMD binary
        if [ -e $(MRW_HB_TOOLS)/memd_creation.pl ]; then \
            chmod +x $(MRW_HB_TOOLS)/memd_creation.pl; \
        fi

        if [ -d $(MRW_SCRATCH)/memd_binaries ]; then \
            $(MRW_HB_TOOLS)/memd_creation.pl -memd_dir $(MRW_SCRATCH)/memd_binaries -memd_output $(MRW_SCRATCH)/memd_output.dat; \
        fi

endef

define MACHINE_XML_INSTALL_IMAGES_CMDS
        mv $(MRW_HB_TOOLS)/targeting.bin $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_TARGETING_BIN_FILENAME)
        if [ -e $(MRW_HB_TOOLS)/targeting.bin.protected ]; then \
            mv -v $(MRW_HB_TOOLS)/targeting.bin.protected $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_TARGETING_BIN_FILENAME).protected; \
        fi
        if [ -e $(MRW_HB_TOOLS)/targeting.bin.unprotected ]; then \
            mv -v $(MRW_HB_TOOLS)/targeting.bin.unprotected $(MRW_HB_TOOLS)/$(BR2_OPENPOWER_TARGETING_BIN_FILENAME).unprotected; \
        fi
endef

define MACHINE_XML_INSTALL_TARGET_CMDS
        # Install Petitboot specific BIOS XML into initramfs's usr/share/ dir
        $(INSTALL) -D -m 0644 \
            $(PETITBOOT_BIOS_XML_METADATA_FILE) \
            $(PETITBOOT_BIOS_XML_METADATA_INITRAMFS_FILE)
endef

$(eval $(generic-package))
