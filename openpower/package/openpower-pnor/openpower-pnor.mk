################################################################################
#
# openpower_pnor
#
################################################################################

OPENPOWER_PNOR_VERSION ?= e582e4ac5941da0e728aecb44e22ecc5ee0ac53a
OPENPOWER_PNOR_SITE ?= $(call github,open-power,pnor,$(OPENPOWER_PNOR_VERSION))

OPENPOWER_PNOR_LICENSE = Apache-2.0
OPENPOWER_PNOR_LICENSE_FILES = LICENSE
OPENPOWER_PNOR_DEPENDENCIES = hostboot-binaries machine-xml skiboot host-openpower-ffs capp-ucode host-openpower-pnor-util

ifeq ($(BR2_OPENPOWER_POWER9),y)
OPENPOWER_PNOR_DEPENDENCIES += hcode
endif

ifeq ($(BR2_PACKAGE_IMA_CATALOG),y)
OPENPOWER_PNOR_DEPENDENCIES += ima-catalog
endif

ifeq ($(BR2_PACKAGE_SKIBOOT_EMBED_PAYLOAD),n)

ifeq ($(BR2_TARGET_ROOTFS_INITRAMFS),y)
OPENPOWER_PNOR_DEPENDENCIES += linux-rebuild-with-initramfs
else
OPENPOWER_PNOR_DEPENDENCIES += linux
endif

endif

ifeq ($(BR2_OPENPOWER_PNOR_XZ_ENABLED),y)
OPENPOWER_PNOR_DEPENDENCIES += host-xz
XZ_ARG=-xz_compression
endif

OPENPOWER_PNOR_DEPENDENCIES += host-sb-signing-utils

ifeq ($(BR2_OPENPOWER_SECUREBOOT_KEY_TRANSITION_TO_DEV),y)
KEY_TRANSITION_ARG=-key_transition imprint
else ifeq ($(BR2_OPENPOWER_SECUREBOOT_KEY_TRANSITION_TO_PROD),y)
KEY_TRANSITION_ARG=-key_transition production
endif

ifneq ($(BR2_OPENPOWER_SECUREBOOT_SIGN_MODE),"")
SIGN_MODE_ARG=-sign_mode $(BR2_OPENPOWER_SECUREBOOT_SIGN_MODE)
endif

ifeq ($(BR2_OPENPOWER_POWER9),y)
    OPENPOWER_RELEASE=p9
endif

OPENPOWER_PNOR_INSTALL_IMAGES = YES
OPENPOWER_PNOR_INSTALL_TARGET = NO

HOSTBOOT_IMAGE_DIR=$(STAGING_DIR)/hostboot_build_images/
HOSTBOOT_BINARY_DIR = $(STAGING_DIR)/hostboot_binaries

HCODE_STAGING_DIR = $(STAGING_DIR)/hcode

SBE_BINARY_DIR = $(STAGING_DIR)/sbe_binaries/
OPENPOWER_PNOR_SCRATCH_DIR = $(STAGING_DIR)/openpower_pnor_scratch/
OPENPOWER_VERSION_DIR = $(STAGING_DIR)/openpower_version
OPENPOWER_MRW_SCRATCH_DIR = $(STAGING_DIR)/openpower_mrw_scratch
OUTPUT_BUILD_DIR = $(STAGING_DIR)/../../../build/
OUTPUT_IMAGES_DIR = $(STAGING_DIR)/../../../images/
HOSTBOOT_BUILD_IMAGES_DIR = $(STAGING_DIR)/hostboot_build_images/
# See Open-Power's Hostboot repo, file: src/build/buildpnor/PnorUtils.pm,
# function: loadPnorLayout(); at the end of that function the generated XML file
# is concatenated with "WithOffsets.xml"
GENERATED_PNOR_LAYOUT_FILES = $(shell find "$(OPENPOWER_PNOR_SCRATCH_DIR)" -maxdepth 1 -name "*WithOffsets.xml")

FILES_TO_TAR = $(HOSTBOOT_BUILD_IMAGES_DIR)/* \
               $(OUTPUT_BUILD_DIR)/skiboot-$(SKIBOOT_VERSION)/skiboot.elf \
               $(OUTPUT_BUILD_DIR)/skiboot-$(SKIBOOT_VERSION)/skiboot.map \
               $(OUTPUT_BUILD_DIR)/linux-$(LINUX_VERSION)/.config \
               $(OUTPUT_BUILD_DIR)/linux-$(LINUX_VERSION)/vmlinux \
               $(OUTPUT_BUILD_DIR)/linux-$(LINUX_VERSION)/System.map \
               $(OUTPUT_IMAGES_DIR)/zImage.epapr \
               $(GENERATED_PNOR_LAYOUT_FILES)

# Subpackages we want to include in the version info (do not include openpower-pnor)
OPENPOWER_VERSIONED_SUBPACKAGES = skiboot

ifeq ($(BR2_PACKAGE_HOSTBOOT),y)
OPENPOWER_VERSIONED_SUBPACKAGES += hostboot occ
endif
ifeq ($(BR2_PACKAGE_OCMB_EXPLORER_FW),y)
OPENPOWER_VERSIONED_SUBPACKAGES += ocmb-explorer-fw
endif
OPENPOWER_VERSIONED_SUBPACKAGES += linux petitboot machine-xml hostboot-binaries capp-ucode
OPENPOWER_PNOR = openpower-pnor

ifeq ($(BR2_OPENPOWER_POWER9),y)
    OPENPOWER_PNOR_DEPENDENCIES += sbe hcode
    OPENPOWER_VERSIONED_SUBPACKAGES += sbe hcode
endif

ifeq ($(BR2_PACKAGE_OCC),y)
    OCC_BIN_FILENAME=$(BR2_OCC_BIN_FILENAME)
endif

ifeq ($(BR2_PACKAGE_OCMB_EXPLORER_FW),y)
    OCMB_EXPLORER_FW_URL=$(call qstrip,$(OCMB_EXPLORER_FW_SITE)/$(OCMB_EXPLORER_FW_SOURCE))
endif

define OPENPOWER_PNOR_INSTALL_IMAGES_CMDS
        mkdir -p $(OPENPOWER_PNOR_SCRATCH_DIR)

        $(TARGET_MAKE_ENV) $(@D)/update_image.pl \
            -release  $(OPENPOWER_RELEASE) \
            -op_target_dir $(HOSTBOOT_IMAGE_DIR) \
            -hb_image_dir $(HOSTBOOT_IMAGE_DIR) \
            -scratch_dir $(OPENPOWER_PNOR_SCRATCH_DIR) \
            -hb_binary_dir $(HOSTBOOT_BINARY_DIR) \
            -hcode_dir $(HCODE_STAGING_DIR) \
            -targeting_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME) \
            -targeting_binary_source $(BR2_OPENPOWER_TARGETING_BIN_FILENAME) \
            -targeting_RO_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME).protected \
            -targeting_RO_binary_source $(BR2_OPENPOWER_TARGETING_BIN_FILENAME).protected \
            -targeting_RW_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME).unprotected \
            -targeting_RW_binary_source $(BR2_OPENPOWER_TARGETING_BIN_FILENAME).unprotected \
            -sbe_binary_filename $(BR2_HOSTBOOT_BINARY_SBE_FILENAME) \
            -sbe_binary_dir $(SBE_BINARY_DIR) \
            -sbec_binary_filename $(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) \
            -wink_binary_filename $(BR2_HOSTBOOT_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(OCC_BIN_FILENAME) \
            -capp_binary_filename $(BINARIES_DIR)/$(BR2_CAPP_UCODE_BIN_FILENAME) \
            -ima_catalog_binary_filename $(BINARIES_DIR)/$(BR2_IMA_CATALOG_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_VERSION_FILE) \
            -wof_binary_filename $(OPENPOWER_MRW_SCRATCH_DIR)/$(BR2_WOFDATA_FILENAME) \
            -memd_binary_filename $(OPENPOWER_MRW_SCRATCH_DIR)/$(BR2_MEMDDATA_FILENAME) \
            -payload $(BINARIES_DIR)/$(BR2_SKIBOOT_LID_NAME) \
            -payload_filename $(BR2_SKIBOOT_LID_XZ_NAME) \
            -binary_dir $(BINARIES_DIR) \
            -bootkernel_filename $(LINUX_IMAGE_NAME) \
	    -ocmbfw_version $(OCMB_EXPLORER_FW_VERSION) \
	    -ocmbfw_url $(OCMB_EXPLORER_FW_URL) \
	    -ocmbfw_original_filename $(BINARIES_DIR)/$(BR2_OCMBFW_FILENAME) \
	    -ocmbfw_binary_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_PROCESSED_FILENAME) \
            -pnor_layout $(@D)/"$(OPENPOWER_RELEASE)"Layouts/$(BR2_OPENPOWER_PNOR_XML_LAYOUT_FILENAME) \
            $(XZ_ARG) $(KEY_TRANSITION_ARG) $(SIGN_MODE_ARG) \

        mkdir -p $(STAGING_DIR)/pnor/
        $(TARGET_MAKE_ENV) $(@D)/create_pnor_image.pl \
            -release $(OPENPOWER_RELEASE) \
            -xml_layout_file $(@D)/"$(OPENPOWER_RELEASE)"Layouts/$(BR2_OPENPOWER_PNOR_XML_LAYOUT_FILENAME) \
            -pnor_filename $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) \
            -hb_image_dir $(HOSTBOOT_IMAGE_DIR) \
            -scratch_dir $(OPENPOWER_PNOR_SCRATCH_DIR) \
            -outdir $(STAGING_DIR)/pnor/ \
            -payload $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_SKIBOOT_LID_XZ_NAME) \
            -bootkernel $(OPENPOWER_PNOR_SCRATCH_DIR)/$(LINUX_IMAGE_NAME) \
            -sbe_binary_filename $(BR2_HOSTBOOT_BINARY_SBE_FILENAME) \
            -sbec_binary_filename $(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) \
            -wink_binary_filename $(BR2_HOSTBOOT_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(OCC_BIN_FILENAME) \
            -targeting_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME) \
            -targeting_RO_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME).protected \
            -targeting_RW_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME).unprotected \
            -wofdata_binary_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_WOFDATA_BINARY_FILENAME) \
            -memddata_binary_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_MEMDDATA_BINARY_FILENAME) \
            -ocmbfw_binary_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_PROCESSED_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/openpower_pnor_version.bin

        $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) $(BINARIES_DIR)

        # if this config has an UPDATE_FILENAME defined, create a 32M (1/2 size)
        # image that only updates the non-golden side
        if [ "$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME)" != "" ]; then \
            dd if=$(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) of=$(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME) bs=32M count=1; \
            $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME) $(BINARIES_DIR); \
        fi

        # If this is a VPNOR system, run the generate-tar command and
        # create a tarball
        if [ "$(BR2_BUILD_PNOR_SQUASHFS)" == "y" ]; then \
            PATH=$(HOST_DIR)/usr/bin:$(PATH) $(HOST_DIR)/usr/bin/generate-tar -i squashfs -m $(BR2_OPENPOWER_CONFIG_NAME) -f $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME).squashfs.tar $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) -s; \
            $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME).squashfs.tar $(BINARIES_DIR); \
        else \
            PATH=$(HOST_DIR)/usr/bin:$(PATH) $(HOST_DIR)/usr/bin/generate-tar -i static -m $(BR2_OPENPOWER_CONFIG_NAME) -f $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME).static.tar.gz $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) -s; \
            $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME).static.tar.gz $(BINARIES_DIR); \
        fi

	#Create Debug Tarball
	mkdir -p $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/
	cp -r $(FILES_TO_TAR) $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/
	tar -zcvf $(OUTPUT_IMAGES_DIR)/host_fw_debug.tar -C $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/  .

endef

$(eval $(generic-package))
# Generate openPOWER pnor version string by combining subpackage version string files
$(eval $(call OPENPOWER_VERSION,$(OPENPOWER_PNOR)))
