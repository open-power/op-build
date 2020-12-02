################################################################################
#
# openpower_pnor_p10
#
################################################################################

OPENPOWER_PNOR_P10_VERSION ?= e8edd241ee640407fad40ba48e3a143d84d04ace

# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#OPENPOWER_PNOR_P10_SITE ?= $(call github,open-power,pnor,$(OPENPOWER_PNOR_P10_VERSION))
OPENPOWER_PNOR_P10_SITE = git@github.ibm.com:open-power/pnor.git
OPENPOWER_PNOR_P10_SITE_METHOD=git

OPENPOWER_PNOR_P10_LICENSE = Apache-2.0
OPENPOWER_PNOR_P10_LICENSE_FILES = LICENSE
OPENPOWER_PNOR_P10_DEPENDENCIES = hostboot-binaries skiboot host-openpower-ffs capp-ucode host-openpower-pnor-util host-xz host-sb-signing-utils hostboot-p10 occ-p10 sbe-p10 hcode-p10 ocmb-explorer-fw $(call qstrip,$(BR2_OPENPOWER_P10_XMLS))

ifeq ($(BR2_PACKAGE_IMA_CATALOG),y)
OPENPOWER_PNOR_P10_DEPENDENCIES += ima-catalog
endif

ifeq ($(BR2_OPENPOWER_P10_SECUREBOOT_KEY_TRANSITION_TO_DEV),y)
OPENPOWER_PNOR_P10_KEY_TRANSITION_ARG = -key_transition imprint
else ifeq ($(BR2_OPENPOWER_P10_SECUREBOOT_KEY_TRANSITION_TO_PROD),y)
OPENPOWER_PNOR_P10_KEY_TRANSITION_ARG = -key_transition production
endif

ifneq ($(BR2_OPENPOWER_P10_SECUREBOOT_SIGN_MODE),"")
OPENPOWER_PNOR_P10_SIGN_MODE_ARG = -sign_mode $(BR2_OPENPOWER_P10_SECUREBOOT_SIGN_MODE)
endif

OPENPOWER_PNOR_P10_INSTALL_IMAGES = YES
OPENPOWER_PNOR_P10_INSTALL_TARGET = NO

# Subpackages we want to include in the version info (do not include openpower-pnor-p10)
# This is used inside pkg-versions.mk
OPENPOWER_PNOR_P10_VERSIONED_SUBPACKAGES = skiboot linux petitboot hostboot-binaries capp-ucode pdata hostboot-p10 occ-p10 sbe-p10 hcode-p10 ocmb-explorer-fw $(call qstrip,$(BR2_OPENPOWER_P10_XMLS))

OPENPOWER_PNOR_P10_OCMB_URL = $(call qstrip,$(OCMB_EXPLORER_FW_SITE)/$(OCMB_EXPLORER_FW_SOURCE))

#######
# OPENPOWER_PNOR_P10_UPDATE_IMAGE - process/sign PNOR partitions
# Arguments:
#     $1 - The target-specific mrw package name (i.e., rainier-2u-xml)
#######
define OPENPOWER_PNOR_P10_UPDATE_IMAGE
        echo "***Signing images for target:$(call qstrip,$(1))"

        $(eval XML_VAR = $$(call UPPERCASE,$$(call qstrip,$(1))))
        echo "***XML_VAR: $(XML_VAR)"

        $(eval TARGETING_BINARY_SOURCE = $$(BR2_$(XML_VAR)_TARGETING_BIN_FILENAME))
        echo "***TARGETING_BINARY_SOURCE: $(TARGETING_BINARY_SOURCE)"

        $(eval TARGETING_BINARY_FILENAME = $$(BR2_$(XML_VAR)_TARGETING_ECC_FILENAME))
        echo "***TARGETING_BINARY_FILENAME: $(TARGETING_BINARY_FILENAME)"

        $(eval XML_FILENAME = $$(call qstrip,$$(BR2_$(XML_VAR)_FILENAME)))
        echo "***XML_FILENAME: $(XML_FILENAME)"

        $(eval WOF_BINARY_FILENAME = $$(patsubst %.xml,%.wofdata,$(XML_FILENAME)))
        echo "***WOF_BINARY_FILENAME: $(WOF_BINARY_FILENAME)"

        $(eval MEMD_BINARY_FILENAME = $$(patsubst %.xml,%.memd_output.dat,$(XML_FILENAME)))
        echo "***MEMD_BINARY_FILENAME: $(MEMD_BINARY_FILENAME)"

        $(eval DEVTREE_BINARY_FILENAME = $$(patsubst %.xml,%.dtb,$(XML_FILENAME)))
        echo "***DEVTREE_BINARY_FILENAME: $(DEVTREE_BINARY_FILENAME)"

        $(eval PNOR_SCRATCH_DIR = $(STAGING_DIR)/openpower_pnor_scratch.$(XML_VAR))
        echo "***PNOR scratch directory: $(PNOR_SCRATCH_DIR)"
        mkdir -p $(PNOR_SCRATCH_DIR)


        $(TARGET_MAKE_ENV) $(@D)/update_image.pl \
            -release p10 \
            -op_target_dir $(STAGING_DIR)/hostboot_build_images \
            -hb_image_dir $(STAGING_DIR)/hostboot_build_images \
            -scratch_dir $(PNOR_SCRATCH_DIR) \
            -hb_binary_dir $(STAGING_DIR)/hostboot_binaries \
            -hcode_dir $(STAGING_DIR)/hcode \
            -targeting_binary_filename $(TARGETING_BINARY_FILENAME) \
            -targeting_binary_source $(TARGETING_BINARY_SOURCE) \
            -targeting_RO_binary_filename $(TARGETING_BINARY_FILENAME).protected \
            -targeting_RO_binary_source $(TARGETING_BINARY_SOURCE).protected \
            -targeting_RW_binary_filename $(TARGETING_BINARY_FILENAME).unprotected \
            -targeting_RW_binary_source $(TARGETING_BINARY_SOURCE).unprotected \
            -sbe_binary_filename $(BR2_HOSTBOOT_P10_BINARY_SBE_FILENAME) \
            -sbe_binary_dir $(STAGING_DIR)/sbe_binaries \
            -sbec_binary_filename $(BR2_HOSTBOOT_P10_BINARY_SBEC_FILENAME) \
            -wink_binary_filename $(BR2_HOSTBOOT_P10_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_P10_BIN_FILENAME) \
            -capp_binary_filename $(BINARIES_DIR)/$(BR2_CAPP_UCODE_BIN_FILENAME) \
            -ima_catalog_binary_filename $(BINARIES_DIR)/$(BR2_IMA_CATALOG_P10_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_P10_VERSION_FILE) \
            -wof_binary_filename $(STAGING_DIR)/openpower_mrw_scratch/$(WOF_BINARY_FILENAME) \
            -memd_binary_filename $(STAGING_DIR)/openpower_mrw_scratch/$(MEMD_BINARY_FILENAME) \
            -payload $(BINARIES_DIR)/$(BR2_SKIBOOT_P10_LID_NAME) \
            -payload_filename skiboot.lid.xz \
            -binary_dir $(BINARIES_DIR) \
            -bootkernel_filename $(LINUX_IMAGE_NAME) \
            -ocmbfw_version $(OCMB_EXPLORER_FW_VERSION) \
            -ocmbfw_url $(OPENPOWER_PNOR_P10_OCMB_URL) \
            -ocmbfw_original_filename $(BINARIES_DIR)/$(BR2_OCMBFW_P10_FILENAME) \
            -ocmbfw_binary_filename $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P10_PROCESSED_FILENAME) \
            -pnor_layout $(@D)/p10Layouts/$(BR2_OPENPOWER_P10_PNOR_XML_LAYOUT_FILENAME) \
            -sbe_img_dir $(BUILD_DIR)/sbe-p10-$(call qstrip,$(BR2_SBE_P10_VERSION))/images \
            -devtree_binary_filename $(STAGING_DIR)/usr/share/pdata/$(DEVTREE_BINARY_FILENAME) \
            -xz_compression \
            $(OPENPOWER_PNOR_P10_KEY_TRANSITION_ARG) \
            $(OPENPOWER_PNOR_P10_SIGN_MODE_ARG)

        if [ -n "$(BR2_OPENPOWER_PNOR_P10_LEGACY_PNOR_TARGET)" ] ; then \
            echo "***Generating legacy pnor targets..." ;\
            mkdir -p $(STAGING_DIR)/pnor.$(XML_VAR) ; \
            $(TARGET_MAKE_ENV) $(@D)/create_pnor_image.pl \
                -release p10 \
                -xml_layout_file $(@D)/p10Layouts/$(BR2_OPENPOWER_P10_PNOR_XML_LAYOUT_FILENAME) \
                -pnor_filename $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor \
                -hb_image_dir $(STAGING_DIR)/hostboot_build_images \
                -scratch_dir $(PNOR_SCRATCH_DIR) \
                -outdir $(STAGING_DIR)/pnor.$(XML_VAR)/ \
                -payload $(PNOR_SCRATCH_DIR)/$(BR2_SKIBOOT_LID_XZ_NAME) \
                -bootkernel $(PNOR_SCRATCH_DIR)/$(LINUX_IMAGE_NAME) \
                -sbe_binary_filename $(BR2_HOSTBOOT_P10_BINARY_SBE_FILENAME) \
                -sbec_binary_filename $(BR2_HOSTBOOT_P10_BINARY_SBEC_FILENAME) \
                -wink_binary_filename $(BR2_HOSTBOOT_P10_BINARY_WINK_FILENAME) \
                -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_P10_BIN_FILENAME) \
                -targeting_binary_filename $(TARGETING_BINARY_FILENAME) \
                -targeting_RO_binary_filename $(TARGETING_BINARY_FILENAME).protected \
                -targeting_RW_binary_filename $(TARGETING_BINARY_FILENAME).unprotected \
                -wofdata_binary_filename $(PNOR_SCRATCH_DIR)/wofdata.bin.ecc \
                -memddata_binary_filename $(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc \
                -ocmbfw_binary_filename $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P10_PROCESSED_FILENAME) \
                -openpower_version_filename $(PNOR_SCRATCH_DIR)/openpower_pnor_version.bin  \
                -devtree_binary_filename $(PNOR_SCRATCH_DIR)/DEVTREE.bin ;\
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor $(BINARIES_DIR) ;\
            PATH=$(HOST_DIR)/usr/bin:$(PATH) $(HOST_DIR)/usr/bin/generate-tar -i squashfs \
                -m $(XML_VAR) \
                -f $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.squashfs.tar \
                $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor -s ;\
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.squashfs.tar $(BINARIES_DIR) ;\
            cd $(STAGING_DIR)/pnor.$(XML_VAR) ;\
            PATH=$(HOST_DIR)/usr/sbin:$(PATH) $(HOST_DIR)/usr/bin/generate-ubi \
                $(XML_VAR).pnor.squashfs.tar ;\
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.ubi.mtd $(BINARIES_DIR) ;\
            $(TARGET_MAKE_ENV) $(@D)/makelidpkg \
                $(BINARIES_DIR)/$(XML_VAR).ebmc_lids.tar.gz \
                $(PNOR_SCRATCH_DIR); \
            if [ -e $(STAGING_DIR)/openpower_pnor_scratch ] ; then \
                echo "*** Reusing existing $(STAGING_DIR)/openpower_pnor_scratch => $$(readlink -f $(STAGING_DIR)/openpower_pnor_scratch)";\
            else \
                ln -rs $(PNOR_SCRATCH_DIR) $(STAGING_DIR)/openpower_pnor_scratch ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).ebmc_lids.tar.gz \
                    $(BINARIES_DIR)/ebmc_lids.tar.gz ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P10_LEGACY_PNOR_TARGET).pnor ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor.squashfs.tar \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P10_LEGACY_PNOR_TARGET).pnor.squashfs.tar ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor.ubi.mtd \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P10_LEGACY_PNOR_TARGET).pnor.ubi.mtd ;\
            fi ;\
        fi
        # Copy images to mmc dir 
        # HBBL
        test -f "$(BINARIES_DIR)/mmc/HBBL.P10" ||\
             $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hbbl.bin.ecc \
                $(BINARIES_DIR)/mmc/HBBL.P10

        # HBB
        test -f "$(BINARIES_DIR)/mmc/HBB.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBB.P10

        # HBI
        test -f "$(BINARIES_DIR)/mmc/HBI.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot_extended.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBI.P10

        # HBD
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(TARGETING_BINARY_FILENAME) \
            $(BINARIES_DIR)/mmc/HBD.$(XML_VAR)

        # SBE
        test -f "$(BINARIES_DIR)/mmc/SBE.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_HOSTBOOT_P10_BINARY_SBE_FILENAME) \
                $(BINARIES_DIR)/mmc/SBE.P10

        # PAYLOAD
        test -f "$(BINARIES_DIR)/mmc/PAYLOAD.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/skiboot.lid.xz \
                $(BINARIES_DIR)/mmc/PAYLOAD.P10

        # HCODE
        test -f "$(BINARIES_DIR)/mmc/HCODE.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_HOSTBOOT_P10_BINARY_WINK_FILENAME) \
                $(BINARIES_DIR)/mmc/HCODE.P10

        # HBRT
        test -f "$(BINARIES_DIR)/mmc/HBRT.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot_runtime.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBRT.P10

        # OCC
        test -f "$(BINARIES_DIR)/mmc/OCC.P10" ||\
            $(INSTALL) -m 0644 -D $(OCC_STAGING_DIR)/$(BR2_OCC_P10_BIN_FILENAME).ecc \
                $(BINARIES_DIR)/mmc/OCC.P10

        # BOOTKERNEL
        test -f "$(BINARIES_DIR)/mmc/BOOTKERNEL.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(LINUX_IMAGE_NAME) \
                $(BINARIES_DIR)/mmc/BOOTKERNEL.P10

        # CAPP
        test -f "$(BINARIES_DIR)/mmc/CAPP.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/cappucode.bin.ecc \
                $(BINARIES_DIR)/mmc/CAPP.P10

        # VERSION
        test -f "$(BINARIES_DIR)/mmc/VERSION.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/openpower_pnor_version.bin \
                $(BINARIES_DIR)/mmc/VERSION.P10

        # IMA_CATALOG
        test -f "$(BINARIES_DIR)/mmc/IMA_CATALOG.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/ima_catalog.bin.ecc \
                $(BINARIES_DIR)/mmc/IMA_CATALOG.P10

        # SBKT (special content)
        test -f "$(BINARIES_DIR)/mmc/SBKT.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/SBKT.bin \
                $(BINARIES_DIR)/mmc/SBKT.P10

        # HBEL (blank)
        test -f "$(BINARIES_DIR)/mmc/HBEL.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hbel.bin.ecc \
                $(BINARIES_DIR)/mmc/HBEL.P10

        # GUARD (blank)
        test -f "$(BINARIES_DIR)/mmc/GUARD.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/guard.bin.ecc \
                $(BINARIES_DIR)/mmc/GUARD.P10

        # HB_VOLATILE (blank)
        test -f "$(BINARIES_DIR)/mmc/HB_VOLATILE.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hb_volatile.bin \
                $(BINARIES_DIR)/mmc/HB_VOLATILE.P10

        # NVRAM (blank)
        test -f "$(BINARIES_DIR)/mmc/NVRAM.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/nvram.bin \
                $(BINARIES_DIR)/mmc/NVRAM.P10

        # ATTR_TMP (blank)
        test -f "$(BINARIES_DIR)/mmc/ATTR_TMP.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/attr_tmp.bin.ecc \
                $(BINARIES_DIR)/mmc/ATTR_TMP.P10

        # ATTR_PERM (blank)
        test -f "$(BINARIES_DIR)/mmc/ATTR_PERM.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/attr_perm.bin.ecc \
                $(BINARIES_DIR)/mmc/ATTR_PERM.P10

        # FIRDATA (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/firdata.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/FIRDATA.P10" || \
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/firdata.bin.ecc \
                    $(BINARIES_DIR)/mmc/FIRDATA.P10 ; \
        fi

        # SECBOOT (blank)
        test -f "$(BINARIES_DIR)/mmc/SECBOOT.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/secboot.bin.ecc \
                $(BINARIES_DIR)/mmc/SECBOOT.P10

        # RINGOVD (blank)
        test -f "$(BINARIES_DIR)/mmc/RINGOVD.P10" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/ringOvd.bin \
                $(BINARIES_DIR)/mmc/RINGOVD.P10

        # CVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/cvpd.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/CVPD.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/cvpd.bin.ecc \
                    $(BINARIES_DIR)/mmc/CVPD.P10 ; \
        fi

        # DJVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/djvpd_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/DJVPD.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/djvpd_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/DJVPD.P10 ; \
        fi

        # MVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/mvpd_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/MVPD.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/mvpd_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/MVPD.P10 ; \
        fi

        # EECACHE (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/eecache_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/EECACHE.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/eecache_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/EECACHE.P10 ; \
        fi

        # WOFDATA
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/wofdata.bin.ecc \
            $(BINARIES_DIR)/mmc/WOFDATA.$(XML_VAR)

        # MEMD (optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/MEMD.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc \
                    $(BINARIES_DIR)/mmc/MEMD.P10 ; \
        fi

        # HDAT
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hdat.bin.ecc \
            $(BINARIES_DIR)/mmc/HDAT.$(XML_VAR)

        # OCMBFW (optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P10_PROCESSED_FILENAME)" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/OCMBFW.P10" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P10_PROCESSED_FILENAME) \
                    $(BINARIES_DIR)/mmc/OCMBFW.P10 ; \
        fi

        # DEVTREE
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/DEVTREE.bin \
            $(BINARIES_DIR)/mmc/DEVTREE.$(XML_VAR)

endef

define OPENPOWER_PNOR_P10_INSTALL_IMAGES_CMDS

        if [ -n "$(BR2_OPENPOWER_PNOR_P10_LEGACY_PNOR_TARGET)" ] ; then  \
            rm -f $(BINARIES_DIR)/*.pnor \
                $(BINARIES_DIR)/*.pnor.squashfs.tar \
                $(BINARIES_DIR)/*.ubi.mtd ;\
            rm -rf $(BINARIES_DIR)/ebmc_lids.tar.gz \
                $(BINARIES_DIR)/*.ebmc_lids.tar.gz ;\
            rm -rf $(STAGING_DIR)/openpower_pnor_scratch \
                $(STAGING_DIR)/openpower_pnor_scratch.* ;\
        fi

        $(foreach xmlpkg,$(BR2_OPENPOWER_P10_XMLS),\
            $(call OPENPOWER_PNOR_P10_UPDATE_IMAGE,\
                $(xmlpkg)))

        # Create MMC Tarball
        tar -zcvf $(BINARIES_DIR)/mmc.tar.gz -C $(BINARIES_DIR) mmc

        # Create Debug Tarball (target-agnostic)
        mkdir -p $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/
        cp -r $(STAGING_DIR)/hostboot_build_images/* \
            $(BUILD_DIR)/skiboot-$(SKIBOOT_VERSION)/skiboot.elf \
            $(BUILD_DIR)/skiboot-$(SKIBOOT_VERSION)/skiboot.map \
            $(BUILD_DIR)/linux-$(LINUX_VERSION)/.config \
            $(BUILD_DIR)/linux-$(LINUX_VERSION)/vmlinux \
            $(BUILD_DIR)/linux-$(LINUX_VERSION)/System.map \
            $(STAGING_DIR)/fsp-trace/fsp-trace \
            $(BINARIES_DIR)/zImage.epapr \
            $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/
        tar -zcvf $(BINARIES_DIR)/host_fw_debug.tar -C $(STAGING_DIR)/pnor/host_fw_debug_tarball_files/  .

endef

$(eval $(generic-package))
# Generate openPOWER pnor version string by combining subpackage version string files
$(eval $(OPENPOWER_VERSION))

