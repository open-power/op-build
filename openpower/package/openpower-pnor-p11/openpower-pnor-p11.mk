################################################################################
#
# openpower_pnor_p11
#
################################################################################
OPENPOWER_PNOR_P11_VERSION ?= c65bd8e9b687438d9db98aa68e8590a497f1173d

#Public
OPENPOWER_PNOR_P11_SITE ?= $(call github,open-power,pnor,$(OPENPOWER_PNOR_P11_VERSION))

#Private
#OPENPOWER_PNOR_P11_SITE ?= git@github.ibm.com:open-power/pnor.git
#OPENPOWER_PNOR_P11_SITE_METHOD ?= git

OPENPOWER_PNOR_P11_LICENSE = Apache-2.0
OPENPOWER_PNOR_P11_LICENSE_FILES = LICENSE
OPENPOWER_PNOR_P11_DEPENDENCIES = hostboot-binaries skiboot host-openpower-ffs host-openpower-pnor-util host-xz host-sb-signing-utils hostboot-p11 occ-p11 sbe-p11 hcode-p11 ocmb-explorer-fw sbe-odyssey $(call qstrip,$(BR2_OPENPOWER_P11_XMLS))

ifeq ($(BR2_PACKAGE_SBE_ODYSSEY),y)
OPENPOWER_PNOR_P11_DEPENDENCIES += sbe-odyssey
endif

ifeq ($(BR2_PACKAGE_IMA_CATALOG),y)
OPENPOWER_PNOR_P11_DEPENDENCIES += ima-catalog
endif

ifeq ($(BR2_OPENPOWER_P11_SECUREBOOT_KEY_TRANSITION_TO_DEV),y)
OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG = -key_transition development
else ifeq ($(BR2_OPENPOWER_P11_SECUREBOOT_KEY_TRANSITION_TO_PROD),y)
OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG = -key_transition production
else ifeq ($(BR2_OPENPOWER_P11_SECUREBOOT_KEY_TRANSITION_PROD_TO_PROD),y)
OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG = -key_transition prod-prod
endif

ifeq ($(BR2_SIGNING_CONTAINER_VERSION),V3)
OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG := $(OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG)-V3
else ifeq ($(BR2_SIGNING_CONTAINER_VERSION),V1)
OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG := $(OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG)-V1
endif

ifneq ($(BR2_OPENPOWER_P11_SECUREBOOT_SIGN_MODE),"")
OPENPOWER_PNOR_P11_SIGN_MODE_ARG = -sign_mode $(BR2_OPENPOWER_P11_SECUREBOOT_SIGN_MODE)
endif

ifneq ($(BR2_OPENPOWER_SIGNED_SECURITY_VERSION),"")
SECURITY_VERSION=-security_version $(BR2_OPENPOWER_SIGNED_SECURITY_VERSION)
endif

OPENPOWER_PNOR_P11_INSTALL_IMAGES = YES
OPENPOWER_PNOR_P11_INSTALL_TARGET = NO

# Subpackages we want to include in the version info (do not include openpower-pnor-p11)
# This is used inside pkg-versions.mk
OPENPOWER_PNOR_P11_VERSIONED_SUBPACKAGES = skiboot linux petitboot hostboot-binaries pdata hostboot-p11 occ-p11 sbe-p11 hcode-p11 ocmb-explorer-fw sbe-odyssey $(call qstrip,$(BR2_OPENPOWER_P11_XMLS))

ifeq ($(BR2_PACKAGE_SBE_ODYSSEY),y)
OPENPOWER_PNOR_P11_VERSIONED_SUBPACKAGES += sbe-odyssey
endif

OPENPOWER_PNOR_P11_OCMB_URL = $(call qstrip,$(OCMB_EXPLORER_FW_SITE)/$(OCMB_EXPLORER_FW_SOURCE))

#######
# OPENPOWER_PNOR_P11_UPDATE_IMAGE - process/sign PNOR partitions
# Arguments:
#     $1 - The target-specific mrw package name (i.e., rainier-2u-xml)
#######
define OPENPOWER_PNOR_P11_UPDATE_IMAGE
        echo "***Signing images for target:$(call qstrip,$(1))"

        $(eval XML_VAR = $$(call UPPERCASE,$$(call qstrip,$(1))))
        echo "***XML_VAR: $(XML_VAR)"

        $(eval TARGETING_BINARY_SOURCE = $$(BR2_$(XML_VAR)_TARGETING_BIN_FILENAME))
        echo "***TARGETING_BINARY_SOURCE: $(TARGETING_BINARY_SOURCE)"

        $(eval TARGETING_BINARY_FILENAME = $$(BR2_$(XML_VAR)_TARGETING_ECC_FILENAME))
        echo "***TARGETING_BINARY_FILENAME: $(TARGETING_BINARY_FILENAME)"

        $(eval XML_FILENAME = $$(call qstrip,$$(BR2_$(XML_VAR)_FILENAME)))
        echo "***XML_FILENAME: $(XML_FILENAME)"

        $(eval PSPD_BINARY_FILENAME = $$(patsubst %.xml,%.PSPD.bin,$(XML_FILENAME)))
        echo "***PSPD_BINARY_FILENAME: $(PSPD_BINARY_FILENAME)"

        $(eval WOF_BINARY_FILENAME = $$(patsubst %.xml,%.wofdata,$(XML_FILENAME)))
        echo "***WOF_BINARY_FILENAME: $(WOF_BINARY_FILENAME)"

        $(eval MEMD_BINARY_FILENAME = $$(patsubst %.xml,%.memd_output.dat,$(XML_FILENAME)))
        echo "***MEMD_BINARY_FILENAME: $(MEMD_BINARY_FILENAME)"

        $(eval DEVTREE_BINARY_FILENAME = $$(patsubst %.xml,%.dtb,$(XML_FILENAME)))
        echo "***DEVTREE_BINARY_FILENAME: $(DEVTREE_BINARY_FILENAME)"

        $(eval PNOR_SCRATCH_DIR = $(STAGING_DIR)/openpower_pnor_scratch.$(XML_VAR))
        echo "***PNOR scratch directory: $(PNOR_SCRATCH_DIR)"
        mkdir -p $(PNOR_SCRATCH_DIR)

        echo "***BINARIES_DIR: $(BINARIES_DIR)"
        echo "***STAGING_DIR: $(STAGING_DIR)"

        $(TARGET_MAKE_ENV) && \
        PATH="$(BUILD_DIR)/sbe-odyssey-$(call qstrip,$(BR2_SBE_ODYSSEY_VERSION))/public/src/import/public/common/utils/imageProcs/tools/:$$PATH" \
         $(@D)/update_image.pl \
            -release p11 \
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
            -sbe_binary_filename $(BR2_HOSTBOOT_P11_BINARY_SBE_FILENAME) \
            -sbe_binary_dir $(STAGING_DIR)/sbe_binaries \
            -wink_binary_filename $(BR2_HOSTBOOT_P11_BINARY_WINK_FILENAME) \
            -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_P11_BIN_FILENAME) \
            -ima_catalog_binary_filename $(BINARIES_DIR)/$(BR2_IMA_CATALOG_P11_FILENAME) \
            -openpower_version_filename $(OPENPOWER_PNOR_P11_VERSION_FILE) \
            -pspd_binary_filename $(STAGING_DIR)/openpower_mrw_scratch/$(PSPD_BINARY_FILENAME) \
            -wof_binary_filename $(STAGING_DIR)/openpower_mrw_scratch/$(WOF_BINARY_FILENAME) \
            -memd_binary_filename $(STAGING_DIR)/openpower_mrw_scratch/$(MEMD_BINARY_FILENAME) \
            -payload $(BINARIES_DIR)/$(BR2_SKIBOOT_P11_LID_NAME) \
            -payload_filename skiboot.lid.xz \
            -binary_dir $(BINARIES_DIR) \
            -bootkernel_filename $(LINUX_IMAGE_NAME) \
            -ocmbfw_version $(OCMB_EXPLORER_FW_VERSION) \
            -ocmbfw_url $(OPENPOWER_PNOR_P11_OCMB_URL) \
            -ocmbfw_original_filename $(BINARIES_DIR)/$(BR2_OCMBFW_P11_FILENAME) \
            -ocmbfw_binary_filename $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P11_PROCESSED_FILENAME) \
            -ody_build sbe-odyssey-$(call qstrip,$(BR2_SBE_ODYSSEY_VERSION)) \
            -ody_rt_pak_file $(STAGING_DIR)/ody_binaries/rt.pak \
            -ody_bldr_pak_file $(STAGING_DIR)/ody_binaries/boot.pak \
            -pnor_layout $(@D)/p11Layouts/$(BR2_OPENPOWER_P11_PNOR_XML_LAYOUT_FILENAME) \
            -sbe_img_dir $(BUILD_DIR)/sbe-p11-$(call qstrip,$(BR2_SBE_P11_VERSION))/images \
            -devtree_binary_filename $(STAGING_DIR)/usr/share/pdata/$(DEVTREE_BINARY_FILENAME) \
            -xz_compression \
            $(OPENPOWER_PNOR_P11_KEY_TRANSITION_ARG) \
            $(OPENPOWER_PNOR_P11_SIGN_MODE_ARG) \
            $(SECURITY_VERSION) \

        if [ -n "$(BR2_OPENPOWER_PNOR_P11_LEGACY_PNOR_TARGET)" ] ; then \
            echo "***Generating legacy pnor targets..." && \
            mkdir -p $(STAGING_DIR)/pnor.$(XML_VAR) && \
            $(TARGET_MAKE_ENV) $(@D)/create_pnor_image.pl \
                -release p11 \
                -xml_layout_file $(@D)/p11Layouts/$(BR2_OPENPOWER_P11_PNOR_XML_LAYOUT_FILENAME) \
                -pnor_filename $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor \
                -hb_image_dir $(STAGING_DIR)/hostboot_build_images \
                -scratch_dir $(PNOR_SCRATCH_DIR) \
                -outdir $(STAGING_DIR)/pnor.$(XML_VAR)/ \
                -payload $(PNOR_SCRATCH_DIR)/$(BR2_SKIBOOT_LID_XZ_NAME) \
                -bootkernel $(PNOR_SCRATCH_DIR)/$(LINUX_IMAGE_NAME) \
                -sbe_binary_filename $(BR2_HOSTBOOT_P11_BINARY_SBE_FILENAME) \
                -wink_binary_filename $(BR2_HOSTBOOT_P11_BINARY_WINK_FILENAME) \
                -occ_binary_filename $(OCC_STAGING_DIR)/$(BR2_OCC_P11_BIN_FILENAME) \
                -targeting_binary_filename $(TARGETING_BINARY_FILENAME) \
                -targeting_RO_binary_filename $(TARGETING_BINARY_FILENAME).protected \
                -targeting_RW_binary_filename $(TARGETING_BINARY_FILENAME).unprotected \
                -wofdata_binary_filename $(PNOR_SCRATCH_DIR)/wofdata.bin.ecc \
                -memddata_binary_filename $(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc \
                -ocmbfw_binary_filename $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P11_PROCESSED_FILENAME) \
                -openpower_version_filename $(PNOR_SCRATCH_DIR)/openpower_pnor_version.bin  \
                -devtree_binary_filename $(PNOR_SCRATCH_DIR)/DEVTREE.bin \
                -pspd_binary_filename $(PNOR_SCRATCH_DIR)/PSPD.bin && \
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor $(BINARIES_DIR) && \
            PATH=$(HOST_DIR)/usr/bin:$(PATH) $(HOST_DIR)/usr/bin/generate-tar -i squashfs \
                -m $(XML_VAR) \
                -f $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.squashfs.tar \
                $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor -s && \
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.squashfs.tar $(BINARIES_DIR) && \
            cd $(STAGING_DIR)/pnor.$(XML_VAR) && \
            PATH=$(HOST_DIR)/usr/sbin:$(PATH) $(HOST_DIR)/usr/bin/generate-ubi \
                $(XML_VAR).pnor.squashfs.tar && \
            $(INSTALL) $(STAGING_DIR)/pnor.$(XML_VAR)/$(XML_VAR).pnor.ubi.mtd $(BINARIES_DIR) && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hostboot_build_images/hb_tooldata.tar.gz $(PNOR_SCRATCH_DIR)/HBTOOLDATA.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hostboot_build_images/hbicore.syms $(PNOR_SCRATCH_DIR)/HBICORE_SYMS.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hostboot_build_images/hbotStringFile $(PNOR_SCRATCH_DIR)/HBOTSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/sbe_sim_data/sbeMeasurementStringFile $(PNOR_SCRATCH_DIR)/SBEMSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/sbe_sim_data/sbeStringFile_DD1 $(PNOR_SCRATCH_DIR)/SBESTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/sbe_sim_data/sbeVerificationStringFile $(PNOR_SCRATCH_DIR)/SBEVSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/ody_stringfiles/runtime/odysseySppeStringFile_DD1 $(PNOR_SCRATCH_DIR)/ODYRTSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/ody_stringfiles/gldn/odysseySppeStringFile_DD1 $(PNOR_SCRATCH_DIR)/ODYGLDNSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(OCC_STAGING_DIR)/occStringFile $(PNOR_SCRATCH_DIR)/OCCSTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hcode/qme_p10dd20/trexStringFile $(PNOR_SCRATCH_DIR)/QMESTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hcode/xgpe_p10dd20/trexStringFile $(PNOR_SCRATCH_DIR)/XGPESTRINGFILE.ipllid && \
            $(INSTALL) -m 0644 -D $(STAGING_DIR)/hcode/pgpe_p10dd20/trexStringFile $(PNOR_SCRATCH_DIR)/PGPESTRINGFILE.ipllid && \
            $(TARGET_MAKE_ENV) $(@D)/makelidpkg \
                $(BINARIES_DIR)/$(XML_VAR).ebmc_lids.tar.gz \
                $(PNOR_SCRATCH_DIR) && \
            if [ -e $(STAGING_DIR)/openpower_pnor_scratch ] ; then \
                echo "*** Reusing existing $(STAGING_DIR)/openpower_pnor_scratch => $$(readlink -f $(STAGING_DIR)/openpower_pnor_scratch)";\
            else \
                ln -rs $(PNOR_SCRATCH_DIR) $(STAGING_DIR)/openpower_pnor_scratch ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).ebmc_lids.tar.gz \
                    $(BINARIES_DIR)/ebmc_lids.tar.gz ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P11_LEGACY_PNOR_TARGET).pnor ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor.squashfs.tar \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P11_LEGACY_PNOR_TARGET).pnor.squashfs.tar ;\
                ln -rs $(BINARIES_DIR)/$(XML_VAR).pnor.ubi.mtd \
                    $(BINARIES_DIR)/$(BR2_OPENPOWER_PNOR_P11_LEGACY_PNOR_TARGET).pnor.ubi.mtd ;\
            fi ;\
        fi
        # Copy images to mmc dir
        # HBBL
        test -f "$(BINARIES_DIR)/mmc/HBBL.P11" ||\
             $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hbbl.bin.ecc \
                $(BINARIES_DIR)/mmc/HBBL.P11

        # HBB
        test -f "$(BINARIES_DIR)/mmc/HBB.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBB.P11

        # HBI
        test -f "$(BINARIES_DIR)/mmc/HBI.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot_extended.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBI.P11

        # HBD.bin SECTION is the COMBO (RO and RW) as built by genPnorImages.pl
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(TARGETING_BINARY_FILENAME) \
            $(BINARIES_DIR)/mmc/HBD.$(XML_VAR)

        # HBD_RW.bin SECTION conditionally built by genPnorImages.pl
        # Not consumed as a LID today since its a PNOR partition
        if [ -e $(PNOR_SCRATCH_DIR)/$(TARGETING_BINARY_FILENAME).unprotected ]; then \
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(TARGETING_BINARY_FILENAME).unprotected \
                $(BINARIES_DIR)/mmc/HBD_RW.$(XML_VAR) ; \
        fi

        # SBE
        test -f "$(BINARIES_DIR)/mmc/SBE.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_HOSTBOOT_P11_BINARY_SBE_FILENAME) \
                $(BINARIES_DIR)/mmc/SBE.P11

        # PAYLOAD
        test -f "$(BINARIES_DIR)/mmc/PAYLOAD.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/skiboot.lid.xz \
                $(BINARIES_DIR)/mmc/PAYLOAD.P11

        # HCODE
        test -f "$(BINARIES_DIR)/mmc/HCODE.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_HOSTBOOT_P11_BINARY_WINK_FILENAME) \
                $(BINARIES_DIR)/mmc/HCODE.P11

        # HBRT
        test -f "$(BINARIES_DIR)/mmc/HBRT.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hostboot_runtime.header.bin.ecc \
                $(BINARIES_DIR)/mmc/HBRT.P11

        # OCC
        test -f "$(BINARIES_DIR)/mmc/OCC.P11" ||\
            $(INSTALL) -m 0644 -D $(OCC_STAGING_DIR)/$(BR2_OCC_P11_BIN_FILENAME).ecc \
                $(BINARIES_DIR)/mmc/OCC.P11

        # BOOTKERNEL
        test -f "$(BINARIES_DIR)/mmc/BOOTKERNEL.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(LINUX_IMAGE_NAME) \
                $(BINARIES_DIR)/mmc/BOOTKERNEL.P11

        # VERSION
        test -f "$(BINARIES_DIR)/mmc/VERSION.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/openpower_pnor_version.bin \
                $(BINARIES_DIR)/mmc/VERSION.P11

        # IMA_CATALOG
        test -f "$(BINARIES_DIR)/mmc/IMA_CATALOG.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/ima_catalog.bin.ecc \
                $(BINARIES_DIR)/mmc/IMA_CATALOG.P11

        # SBKT (special content)
        test -f "$(BINARIES_DIR)/mmc/SBKT.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/SBKT.bin \
                $(BINARIES_DIR)/mmc/SBKT.P11

        # HBEL (blank)
        test -f "$(BINARIES_DIR)/mmc/HBEL.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hbel.bin.ecc \
                $(BINARIES_DIR)/mmc/HBEL.P11

        # GUARD (blank)
        test -f "$(BINARIES_DIR)/mmc/GUARD.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/guard.bin.ecc \
                $(BINARIES_DIR)/mmc/GUARD.P11

        # HB_VOLATILE (blank)
        test -f "$(BINARIES_DIR)/mmc/HB_VOLATILE.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hb_volatile.bin \
                $(BINARIES_DIR)/mmc/HB_VOLATILE.P11

        # NVRAM (blank)
        test -f "$(BINARIES_DIR)/mmc/NVRAM.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/nvram.bin \
                $(BINARIES_DIR)/mmc/NVRAM.P11

        # ATTR_TMP (blank)
        test -f "$(BINARIES_DIR)/mmc/ATTR_TMP.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/attr_tmp.bin.ecc \
                $(BINARIES_DIR)/mmc/ATTR_TMP.P11

        # ATTR_PERM (blank)
        test -f "$(BINARIES_DIR)/mmc/ATTR_PERM.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/attr_perm.bin.ecc \
                $(BINARIES_DIR)/mmc/ATTR_PERM.P11

        # FIRDATA (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/firdata.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/FIRDATA.P11" || \
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/firdata.bin.ecc \
                    $(BINARIES_DIR)/mmc/FIRDATA.P11 ; \
        fi

        # SECBOOT (blank)
        test -f "$(BINARIES_DIR)/mmc/SECBOOT.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/secboot.bin.ecc \
                $(BINARIES_DIR)/mmc/SECBOOT.P11

        # RINGOVD (blank)
        test -f "$(BINARIES_DIR)/mmc/RINGOVD.P11" ||\
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/ringOvd.bin \
                $(BINARIES_DIR)/mmc/RINGOVD.P11

        # CVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/cvpd.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/CVPD.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/cvpd.bin.ecc \
                    $(BINARIES_DIR)/mmc/CVPD.P11 ; \
        fi

        # DJVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/djvpd_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/DJVPD.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/djvpd_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/DJVPD.P11 ; \
        fi

        # MVPD (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/mvpd_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/MVPD.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/mvpd_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/MVPD.P11 ; \
        fi

        # EECACHE (blank, optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/eecache_fill.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/EECACHE.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/eecache_fill.bin.ecc \
                    $(BINARIES_DIR)/mmc/EECACHE.P11 ; \
        fi

        # WOFDATA
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/wofdata.bin.ecc \
            $(BINARIES_DIR)/mmc/WOFDATA.$(XML_VAR)

        # MEMD (optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/MEMD.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/memd_extra_data.bin.ecc \
                    $(BINARIES_DIR)/mmc/MEMD.P11 ; \
        fi

        # HDAT
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/hdat.bin.ecc \
            $(BINARIES_DIR)/mmc/HDAT.$(XML_VAR)

        # OCMBFW (optional)
        if [ -f "$(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P11_PROCESSED_FILENAME)" ] ; then \
            test -f "$(BINARIES_DIR)/mmc/OCMBFW.P11" ||\
                $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/$(BR2_OCMBFW_P11_PROCESSED_FILENAME) \
                    $(BINARIES_DIR)/mmc/OCMBFW.P11 ; \
        fi

        # DEVTREE
        $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/DEVTREE.bin \
            $(BINARIES_DIR)/mmc/DEVTREE.$(XML_VAR)

        # PSPD.bin SECTION conditionally built by genPnorImages.pl
        if [ -e $(PNOR_SCRATCH_DIR)/PSPD.bin ]; then \
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/PSPD.bin \
                $(BINARIES_DIR)/mmc/PSPD.$(XML_VAR) ; \
        fi

        # HB_HLL - check as this support is being phased in
        if [ -e $(PNOR_SCRATCH_DIR)/HB_HLL.bin ]; then \
            $(INSTALL) -m 0644 -D $(PNOR_SCRATCH_DIR)/HB_HLL.bin \
                $(BINARIES_DIR)/mmc/HB_HLL.$(XML_VAR) ; \
        fi

endef

define OPENPOWER_PNOR_P11_INSTALL_IMAGES_CMDS

        # CLEANUP OLD IMAGES
        if [ -n "$(BR2_OPENPOWER_PNOR_P11_LEGACY_PNOR_TARGET)" ] ; then  \
            rm -f $(BINARIES_DIR)/*.pnor \
                $(BINARIES_DIR)/*.pnor.squashfs.tar \
                $(BINARIES_DIR)/*.ubi.mtd ;\
            rm -rf $(BINARIES_DIR)/ebmc_lids.tar.gz \
                $(BINARIES_DIR)/*.ebmc_lids.tar.gz ;\
            rm -rf $(STAGING_DIR)/openpower_pnor_scratch \
                $(STAGING_DIR)/openpower_pnor_scratch.* ;\
            rm -rf $(BINARIES_DIR)/mmc \
                $(BINARIES_DIR)/mmc.tar.gz ;\
        fi

        $(foreach xmlpkg,$(BR2_OPENPOWER_P11_XMLS),\
            $(call OPENPOWER_PNOR_P11_UPDATE_IMAGE,\
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
