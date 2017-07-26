################################################################################
#
# openpower_pnor
#
################################################################################

OPENPOWER_PNOR_VERSION ?= 7dd93556bcefdb96483e413bbd650e3929db2769
OPENPOWER_PNOR_SITE ?= $(call github,open-power,pnor,$(OPENPOWER_PNOR_VERSION))

OPENPOWER_PNOR_LICENSE = Apache-2.0
OPENPOWER_PNOR_LICENSE_FILES = LICENSE
OPENPOWER_PNOR_DEPENDENCIES = hostboot hostboot-binaries machine-xml skiboot host-openpower-ffs occ capp-ucode

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
endif

ifeq ($(BR2_OPENPOWER_POWER9),y)
    OPENPOWER_RELEASE=p9
else
    OPENPOWER_RELEASE=p8
endif


OPENPOWER_PNOR_INSTALL_IMAGES = YES
OPENPOWER_PNOR_INSTALL_TARGET = NO

HOSTBOOT_IMAGE_DIR=$(STAGING_DIR)/hostboot_build_images/
HOSTBOOT_BINARY_DIR = $(STAGING_DIR)/hostboot_binaries/
SBE_BINARY_DIR = $(STAGING_DIR)/sbe_binaries/
OPENPOWER_PNOR_SCRATCH_DIR = $(STAGING_DIR)/openpower_pnor_scratch/
OPENPOWER_VERSION_DIR = $(STAGING_DIR)/openpower_version
OPENPOWER_MRW_SCRATCH_DIR = $(STAGING_DIR)/openpower_mrw_scratch

# Subpackages we want to include in the version info (do not include openpower-pnor)
OPENPOWER_VERSIONED_SUBPACKAGES = skiboot hostboot linux petitboot machine-xml occ hostboot-binaries capp-ucode
OPENPOWER_PNOR = openpower-pnor

ifeq ($(BR2_OPENPOWER_POWER9),y)
    OPENPOWER_PNOR_DEPENDENCIES += sbe
    OPENPOWER_VERSIONED_SUBPACKAGES += sbe
endif

define OPENPOWER_PNOR_INSTALL_IMAGES_CMDS
        mkdir -p $(OPENPOWER_PNOR_SCRATCH_DIR)

        $(TARGET_MAKE_ENV) $(@D)/update_image.pl \
            -release  $(OPENPOWER_RELEASE) \
            -op_target_dir $(HOSTBOOT_IMAGE_DIR) \
            -hb_image_dir $(HOSTBOOT_IMAGE_DIR) \
            -scratch_dir $(OPENPOWER_PNOR_SCRATCH_DIR) \
            -hb_binary_dir $(HOSTBOOT_BINARY_DIR) \
            -targeting_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME) \
            -targeting_binary_source $(BR2_OPENPOWER_TARGETING_BIN_FILENAME) \
            -sbe_binary_filename $(BR2_HOSTBOOT_BINARY_SBE_FILENAME) \
            -sbe_binary_dir $(SBE_BINARY_DIR) \
            -sbec_binary_filename $(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) \
            -wink_binary_filename $(BR2_HOSTBOOT_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_BIN_FILENAME) \
            -capp_binary_filename $(BINARIES_DIR)/$(BR2_CAPP_UCODE_BIN_FILENAME) \
            -ima_catalog_binary_filename $(BINARIES_DIR)/$(BR2_IMA_CATALOG_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_VERSION_FILE) \
            -wof_binary_filename $(OPENPOWER_MRW_SCRATCH_DIR)/$(BR2_WOFDATA_FILENAME) \
            -payload $(BINARIES_DIR)/$(BR2_SKIBOOT_LID_NAME) \
            $(if ($(BR2_OPENPOWER_PNOR_XZ_ENABLED),y),-xz_compression)

        mkdir -p $(STAGING_DIR)/pnor/
        $(TARGET_MAKE_ENV) $(@D)/create_pnor_image.pl \
            -release $(OPENPOWER_RELEASE) \
            -xml_layout_file $(@D)/"$(OPENPOWER_RELEASE)"Layouts/$(BR2_OPENPOWER_PNOR_XML_LAYOUT_FILENAME) \
            -pnor_filename $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) \
            -hb_image_dir $(HOSTBOOT_IMAGE_DIR) \
            -scratch_dir $(OPENPOWER_PNOR_SCRATCH_DIR) \
            -outdir $(STAGING_DIR)/pnor/ \
            -payload $(BINARIES_DIR)/$(BR2_SKIBOOT_LID_XZ_NAME) \
            -bootkernel $(BINARIES_DIR)/$(LINUX_IMAGE_NAME) \
            -sbe_binary_filename $(BR2_HOSTBOOT_BINARY_SBE_FILENAME) \
            -sbec_binary_filename $(BR2_HOSTBOOT_BINARY_SBEC_FILENAME) \
            -wink_binary_filename $(BR2_HOSTBOOT_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_BIN_FILENAME) \
            -targeting_binary_filename $(BR2_OPENPOWER_TARGETING_ECC_FILENAME) \
            -wofdata_binary_filename $(OPENPOWER_PNOR_SCRATCH_DIR)/$(BR2_WOFDATA_BINARY_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_VERSION_FILE)

        $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) $(BINARIES_DIR)

        # if this config has an UPDATE_FILENAME defined, create a 32M (1/2 size)
        # image that only updates the non-golden side
        if [ "$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME)" != "" ]; then \
            dd if=$(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_FILENAME) of=$(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME) bs=32M count=1; \
            $(INSTALL) $(STAGING_DIR)/pnor/$(BR2_OPENPOWER_PNOR_UPDATE_FILENAME) $(BINARIES_DIR); \
        fi
endef

$(eval $(generic-package))
# Generate openPOWER pnor version string by combining subpackage version string files
$(eval $(call OPENPOWER_VERSION,$(OPENPOWER_PNOR)))
