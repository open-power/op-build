################################################################################
#
#  sb-signing-framework
#
################################################################################

SB_SIGNING_FRAMEWORK_SITE ?= $(call github,open-power,sb-signing-framework,$(SB_SIGNING_FRAMEWORK_VERSION))

SB_SIGNING_FRAMEWORK_LICENSE = Apache-2.0
SB_SIGNING_FRAMEWORK_LICENSE_FILES = LICENSE
SB_SIGNING_FRAMEWORK_VERSION ?= 274274088fcadb9b909d5bc4ad3e04a2cfdcce43

HOST_SB_SIGNING_FRAMEWORK_DEPENDENCIES = host-openssl host-libcurl host-json-c

define HOST_SB_SIGNING_FRAMEWORK_BUILD_CMDS
	CFLAGS=" -I$(HOST_DIR)/include -L$(HOST_DIR)/lib -L$(HOST_DIR)/lib64 -Wl,-rpath,$(HOST_DIR)/lib -Wl,-rpath,$(HOST_DIR)/lib64 " \
		$(HOST_MAKE_ENV) $(MAKE) -C $(@D)/src/client-c++/
endef

define HOST_SB_SIGNING_FRAMEWORK_COPY_FILES
		$(INSTALL) -m 0755 $(@D)/src/client-c++/sf_client $(HOST_DIR)/bin/
endef

HOST_SB_SIGNING_FRAMEWORK_POST_INSTALL_HOOKS += HOST_SB_SIGNING_FRAMEWORK_COPY_FILES

$(eval $(host-generic-package))

