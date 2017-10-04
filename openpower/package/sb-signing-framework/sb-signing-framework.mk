################################################################################
#
#  signframework
#
################################################################################

SB_SIGNING_FRAMEWORK_SITE ?= $(call github,open-power,sb-signing-framework,$(SB_SIGNING_FRAMEWORK_VERSION))

SB_SIGNING_FRAMEWORK_LICENSE = Apache-2.0
SB_SIGNING_FRAMEWORK_LICENSE_FILES = LICENSE
SB_SIGNING_FRAMEWORK_VERSION ?= master

HOST_SB_SIGNING_FRAMEWORK_DEPENDENCIES = host-openssl

define HOST_SB_SIGNING_FRAMEWORK_BUILD_CMDS
	CFLAGS="-I $(HOST_DIR)/usr/include -Wl,-rpath -Wl,$(HOST_DIR)/usr/lib" \
		$(HOST_MAKE_ENV) $(MAKE) -C $(@D)/src/client/
endef

define HOST_SB_SIGNING_FRAMEWORK_COPY_FILES
	cp -p $(@D)/src/client/sf_client $(HOST_DIR)/usr/bin/
	chmod 755 $(HOST_DIR)/usr/bin/
endef

HOST_SB_SIGNING_FRAMEWORK_POST_INSTALL_HOOKS += HOST_SB_SIGNING_FRAMEWORK_COPY_FILES

$(eval $(host-generic-package))
