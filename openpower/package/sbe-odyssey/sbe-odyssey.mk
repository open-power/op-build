
SBE_ODYSSEY_VERSION = $(call qstrip,$(BR2_SBE_ODYSSEY_VERSION))
SBE_ODYSSEY_SITE ?= git@github.ibm.com:open-power/sbe-common.git
SBE_ODYSSEY_SITE_METHOD = git

SBE_ODYSSEY_LICENSE = Apache-2.0
SBE_ODYSSEY_DEPENDENCIES = host-ppe42-gcc host-meson host-python3 op-image-tools

SBE_ODYSSEY_INSTALL_IMAGES = YES
SBE_ODYSSEY_INSTALL_TARGET = NO

CMD_VARS = LD_LIBRARY_PATH=$(HOST_DIR)/lib PATH="$(HOST_DIR)/bin:$$PATH"

OP_IMAGE_TOOLS_PATH = $(BUILD_DIR)/op-image-tools-$(BR2_OP_IMAGE_TOOLS_VERSION)
HB_BINARY_VERSION = $(call qstrip,$(BR2_HOSTBOOT_BINARIES_VERSION))
define SBE_ODYSSEY_BUILD_CMDS
	$(CMD_VARS) bash -c "python3 -m ensurepip"
	echo 'export LD_LIBRARY_PATH=$(HOST_DIR)/lib:$$LD_LIBRARY_PATH' >> $(@D)/customrc
	echo 'export PPETOOLS=$(PPE42_GCC_BIN)' >> $(@D)/customrc
	echo 'export USER_BIN_DIR=$(@D)/.venv/bin' >> $(@D)/customrc
	echo 'export PYTHONUSERBASE="$(HOST_DIR)"' >> $(@D)/customrc
	echo 'export PYTHON_USER_PACKAGE_PATH="$(wildcard $(HOST_DIR)/lib/python*/site-packages)"' >> $(@D)/customrc
	echo '. .venv/bin/activate' >> $(@D)/customrc
	sed -i 's/--user//g' $(@D)/public/src/tools/utils/sbe/sbe-workon-utils
	$(HOST_DIR)/bin/python3 -m venv $(@D)/.venv --prompt="SBE"
	cd $(@D) && ./internal/src/test/framework/build-script odyssey pnor --skip-tests
	BR2_OPENPOWER_SIGNED_SECURITY_VERSION=${BR2_OPENPOWER_SIGNED_SECURITY_VERSION} $(OP_IMAGE_TOOLS_PATH)/imageBuild/imageBuild.py --sbe $(BUILD_DIR)/sbe-odyssey-$(BR2_SBE_ODYSSEY_VERSION)/ --ovrd $(BUILD_DIR)/hostboot-binaries-$(BR2_HOSTBOOT_BINARIES_VERSION)/ -o $(STAGING_DIR)/ody-pak-files --build_workdir $(STAGING_DIR)/ody-pak-files.work $(OP_IMAGE_TOOLS_PATH)/imageBuild/configs/odyssey/dd1/ody_pnor_dd1_image_config
endef

define SBE_ODYSSEY_INSTALL_IMAGES_CMDS
	mkdir -p $(STAGING_DIR)/ody_binaries
	mkdir -p $(STAGING_DIR)/poz_debug_tools
        mkdir -p $(STAGING_DIR)/ody_stringfiles/runtime
        mkdir -p $(STAGING_DIR)/ody_stringfiles/gldn
        cp $(STAGING_DIR)/ody-pak-files/gen/final/boot.pak $(STAGING_DIR)/ody_binaries/
        cp $(STAGING_DIR)/ody-pak-files/gen/final/rt.pak $(STAGING_DIR)/ody_binaries/
        cp $(@D)/images/odyssey/odyssey_sbe_debug_DD1.tar.gz $(STAGING_DIR)/poz_debug_tools/
		cp $(@D)/images/sbe_tools.tar.gz $(STAGING_DIR)/poz_debug_tools/
        cp $(@D)/images/odyssey/runtime/sppe/odysseySppeStringFile_DD1 $(STAGING_DIR)/ody_stringfiles/runtime/
        tar -xvf $(BUILD_DIR)/hostboot-binaries-$(HB_BINARY_VERSION)/sbe_images/odyssey_dd1_0/golden/ody_sbe_golden_debug.tar.gz sppe/odysseySppeStringFile_DD1
        cp sppe/odysseySppeStringFile_DD1 $(STAGING_DIR)/ody_stringfiles/gldn/
        rm  -rf sppe/
endef

$(eval $(generic-package))
