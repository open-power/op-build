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

HOST_SB_SIGNING_UTILS_AUTORECONF = YES

SB_SIGNING_UTILS_KEY_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/keys
SB_SIGNING_UTILS_KEY_DST_PATH=$(HOST_DIR)/etc/keys

define COPY_KEYS_TO_DESTINATION
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_DST_PATH)
endef

HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += COPY_KEYS_TO_DESTINATION

$(eval $(host-autotools-package))
