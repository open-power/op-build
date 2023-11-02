################################################################################
#
#  sb-signing-framework
#
################################################################################

SB_SIGNING_FRAMEWORK_SITE ?= $(call github,open-power,sb-signing-framework,$(SB_SIGNING_FRAMEWORK_VERSION))

SB_SIGNING_FRAMEWORK_LICENSE = Apache-2.0
SB_SIGNING_FRAMEWORK_LICENSE_FILES = LICENSE
SB_SIGNING_FRAMEWORK_VERSION ?= 5669903e52065ba32065d2926f0693441c104df2

HOST_SB_SIGNING_FRAMEWORK_DEPENDENCIES = host-openssl host-libcurl host-json-c

define HOST_SB_SIGNING_FRAMEWORK_BUILD_CMDS
	CFLAGS="-I $(HOST_DIR)/include -Wl,-rpath -Wl,$(HOST_DIR)/lib" \
		$(HOST_MAKE_ENV) $(MAKE) -C $(@D)/src/client/
endef

define HOST_SB_SIGNING_FRAMEWORK_COPY_FILES
		$(INSTALL) -m 0755 $(@D)/src/client/sf_client $(HOST_DIR)/bin/
endef

HOST_SB_SIGNING_FRAMEWORK_POST_INSTALL_HOOKS += HOST_SB_SIGNING_FRAMEWORK_COPY_FILES

$(eval $(host-generic-package))

