################################################################################
#
#  signframework
#
################################################################################

SIGNFRAMEWORK_SITE ?= $(call github,open-power,sb-signing-framework,$(SIGNFRAMEWORK_VERSION))

SIGNFRAMEWORK_LICENSE = Apache-2.0
SIGNFRAMEWORK_LICENSE_FILES = LICENSE
SIGNFRAMEWORK_VERSION ?= master

HOST_SIGNFRAMEWORK_DEPENDENCIES = host-openssl

define HOST_SIGNFRAMEWORK_BUILD_CMDS
	CFLAGS="-I $(HOST_DIR)/usr/include -Wl,-rpath -Wl,$(HOST_DIR)/usr/lib" $(HOST_MAKE_ENV) $(MAKE) -C $(@D)/src/client/
endef

define HOST_SIGNFRAMEWORK_COPY_FILES
	cp -p $(@D)/src/client/sf_client $(HOST_DIR)/usr/bin/
	chmod 755 $(HOST_DIR)/usr/bin/
endef

HOST_SIGNFRAMEWORK_POST_INSTALL_HOOKS += HOST_SIGNFRAMEWORK_COPY_FILES

$(eval $(host-generic-package))
