################################################################################
#
#  sb-signing-utils
#
################################################################################

SB_SIGNING_UTILS_SITE ?= $(call github,open-power,sb-signing-utils,$(SB_SIGNING_UTILS_VERSION))

SB_SIGNING_UTILS_LICENSE = Apache-2.0
SB_SIGNING_UTILS_LICENSE_FILES = LICENSE
SB_SIGNING_UTILS_VERSION ?= 3088a4026e1216039bd814cb5e369808591f76c5

HOST_SB_SIGNING_UTILS_DEPENDENCIES = host-openssl

HOST_SB_SIGNING_UTILS_AUTORECONF = YES
HOST_SB_SIGNING_UTILS_AUTORECONF_OPTS = -i

define HOST_SB_SIGNING_UTILS_COPY_FILES
	$(INSTALL) -m 0755 $(@D)/crtSignedContainer.sh $(HOST_DIR)/usr/bin/
endef

SB_SIGNING_UTILS_KEY_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/keys
SB_SIGNING_UTILS_KEY_DST_PATH=$(HOST_DIR)/etc/keys

define HOST_SB_SIGNING_UTILS_COPY_KEYS
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_DST_PATH)
endef

HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += HOST_SB_SIGNING_UTILS_COPY_FILES
HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += HOST_SB_SIGNING_UTILS_COPY_KEYS

$(eval $(host-autotools-package))
