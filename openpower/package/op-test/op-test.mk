################################################################################
#
# op-test
#
################################################################################

OP_TEST_VERSION = $(call qstrip,$(BR2_OP_TEST_VERSION))
OP_TEST_SITE = $(call github,open-power,op-test,$(OP_TEST_VERSION))

OP_TEST_LICENSE = Apache-2.0

OP_TEST_LICENSE_FILES = LICENSE

OP_TEST_INSTALL_TARGET = NO
OP_TEST_INSTALL_IMAGES = YES

# surely there's an easier way to make a "clean" copy of the git tree
define OP_TEST_INSTALL_IMAGES_CMDS
	mkdir -p $(BINARIES_DIR)/op-test
	tar -C $(BINARIES_DIR)/op-test/ -xf $(OP_TEST_DL_DIR)/op-test-$(OP_TEST_VERSION).tar.gz
endef

$(eval $(generic-package))
