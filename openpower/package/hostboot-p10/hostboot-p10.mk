################################################################################
#
# Hostboot for POWER10
#
################################################################################

HOSTBOOT_P10_VERSION = $(call qstrip,$(BR2_HOSTBOOT_P10_VERSION))
# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#HOSTBOOT_P10_SITE ?= $(call github,open-power,hostboot,$(HOSTBOOT_P10_VERSION))
HOSTBOOT_P10_SITE = git@github.ibm.com:open-power/hostboot.git
HOSTBOOT_P10_SITE_METHOD=git

HOSTBOOT_P10_LICENSE = Apache-2.0
HOSTBOOT_P10_LICENSE_FILES = LICENSE
HOSTBOOT_P10_DEPENDENCIES = host-binutils

HOSTBOOT_P10_INSTALL_IMAGES = YES
HOSTBOOT_P10_INSTALL_TARGET = NO

HOSTBOOT_P10_ENV_VARS=$(TARGET_MAKE_ENV) PERL_USE_UNSAFE_INC=1 \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_P10_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX="$(CCACHE) $(TARGET_CROSS)" HOST_PREFIX="" HOST_BINUTILS_DIR=$(HOST_BINUTILS_DIR) \
    HOSTBOOT_VERSION=`cat $(HOSTBOOT_P10_VERSION_FILE)`

# TODO: WORKAROUND: Currently the git clone causes a bad symlink
# to be created for src/include/usr/tracinterface.H; so delete it and rebuild it
# manually
define HOSTBOOT_P10_BUILD_CMDS
        $(HOSTBOOT_P10_ENV_VARS) bash -c 'cd $(@D) && rm -f src/include/usr/tracinterface.H && cp src/include/usr/trace/interface.H src/include/usr/tracinterface.H && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_P10_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
