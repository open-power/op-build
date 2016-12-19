################################################################################
#
#  sb-signing-utils
#
################################################################################

SB_SIGNING_UTILS_SITE ?= $(call github,open-power,sb-signing-utils,$(SB_SIGNING_UTILS_VERSION))
SB_SIGNING_UTILS_VERSION ?= 6d0ba6519d719227daaeae96a3b00f0d953e3af1

SB_SIGNING_UTILS_LICENSE = Apache-2.0
SB_SIGNING_UTILS_LICENSE_FILES = LICENSE

HOST_SB_SIGNING_UTILS_DEPENDENCIES = host-openssl

#TODO: Remove chmod below when signing utilities are released as non-patches
#    since the buildroot patch tool does not configure permissions
define HOST_SB_SIGNING_UTILS_CONFIGURE_CMDS
	(cd $(@D); \
		chmod 755 bootstrap.sh; \
		./bootstrap.sh; \
		chmod 755 configure; \
		$(HOST_CONFIGURE_) \
		$(HOST_CONFIGURE_OPTS) \
		./configure \
		--prefix=$(HOST_DIR)/usr \
		--libdir=$(HOST_DIR)/lib \
	)
endef

define HOST_SB_SIGNING_UTILS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

SB_SIGNING_UTILS_KEY_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/keys
SB_SIGNING_UTILS_KEY_DST_PATH=$(HOST_DIR)/etc/keys

define HOST_SB_SIGNING_UTILS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_DST_PATH)

endef

$(eval $(generic-package))
$(eval $(host-generic-package))
