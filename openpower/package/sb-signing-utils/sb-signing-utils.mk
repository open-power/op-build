################################################################################
#
#  sb-signing-utils
#
################################################################################

SB_SIGNING_UTILS_SITE ?= $(call github,hellerda,sb-signing-utils,$(SB_SIGNING_UTILS_VERSION))
SB_SIGNING_UTILS_SITE_VERSION = master

SB_SIGNING_UTILS_LICENSE = Apache-2.0
SB_SIGNING_UTILS_LICENSE_FILES = LICENSE
SB_SIGNING_UTILS_VERSION ?= 4f6ed53e453efb5f57b6301c7f086478f71b757b

HOST_SB_SIGNING_UTILS_DEPENDENCIES = host-openssl

HOST_SB_SIGNING_UTILS_AUTORECONF = YES
HOST_SB_SIGNING_UTILS_AUTORECONF_OPTS = -i

define COPY_FILES_TO_DESTINATION
	$(INSTALL) -m 0755 $(@D)/crtSignedContainer.sh $(HOST_DIR)/usr/bin/
endef

SB_SIGNING_UTILS_KEY_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/keys
SB_SIGNING_UTILS_KEY_DST_PATH=$(HOST_DIR)/etc/keys

define COPY_KEYS_TO_DESTINATION
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_DST_PATH)
endef

HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += COPY_FILES_TO_DESTINATION
HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += COPY_KEYS_TO_DESTINATION

$(eval $(host-autotools-package))
