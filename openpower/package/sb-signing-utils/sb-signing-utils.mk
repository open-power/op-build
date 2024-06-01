################################################################################
#
#  sb-signing-utils
#
################################################################################

SB_SIGNING_UTILS_SITE ?= $(call github,open-power,sb-signing-utils,$(SB_SIGNING_UTILS_VERSION))

SB_SIGNING_UTILS_LICENSE = Apache-2.0
SB_SIGNING_UTILS_LICENSE_FILES = LICENSE
SB_SIGNING_UTILS_VERSION ?= e4fa7b63ca3ff628a8036ce1d6a55acd2be86da6

HOST_SB_SIGNING_UTILS_DEPENDENCIES = host-openssl
ifeq ($(BR2_PACKAGE_HOST_MLCA_FRAMEWORK),y)
HOST_SB_SIGNING_UTILS_DEPENDENCIES = host-mlca_framework
endif

ifeq ($(BR2_OPENPOWER_SECUREBOOT_SIGN_MODE),production)
HOST_SB_SIGNING_UTILS_DEPENDENCIES += host-sb-signing-framework
else ifeq ($(BR2_OPENPOWER_SECUREBOOT_KEY_TRANSITION_TO_PROD),y)
HOST_SB_SIGNING_UTILS_DEPENDENCIES += host-sb-signing-framework
else ifeq ($(BR2_OPENPOWER_P10_SECUREBOOT_SIGN_MODE),production)
HOST_SB_SIGNING_UTILS_DEPENDENCIES += host-sb-signing-framework
else ifeq ($(BR2_OPENPOWER_P10_SECUREBOOT_KEY_TRANSITION_TO_PROD),y)
HOST_SB_SIGNING_UTILS_DEPENDENCIES += host-sb-signing-framework
endif

HOST_SB_SIGNING_UTILS_AUTORECONF = YES
HOST_SB_SIGNING_UTILS_AUTORECONF_OPTS = -i
ifeq ($(BR2_PACKAGE_HOST_MLCA_FRAMEWORK),y)
HOST_SB_SIGNING_UTILS_CONF_OPTS = --enable-sign-v2
endif

define HOST_SB_SIGNING_UTILS_COPY_FILES
	$(INSTALL) -m 0755 $(@D)/crtSignedContainer.sh $(HOST_DIR)/usr/bin/
endef

SB_SIGNING_UTILS_KEY_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/keys
SB_SIGNING_UTILS_KEY_DST_PATH=$(HOST_DIR)/etc/keys
SB_SIGNING_UTILS_KEY_V2_SRC_PATH=$(BR2_EXTERNAL)/package/sb-signing-utils/v2_keys
SB_SIGNING_UTILS_KEY_V2_DST_PATH=$(HOST_DIR)/etc/v2_keys

define HOST_SB_SIGNING_UTILS_COPY_KEYS
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_DST_PATH)
	$(INSTALL) -d -m 0755 $(SB_SIGNING_UTILS_KEY_V2_DST_PATH)
	$(INSTALL) -m 0755 $(SB_SIGNING_UTILS_KEY_V2_SRC_PATH)/* \
		$(SB_SIGNING_UTILS_KEY_V2_DST_PATH)
endef

HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += HOST_SB_SIGNING_UTILS_COPY_FILES
HOST_SB_SIGNING_UTILS_POST_INSTALL_HOOKS += HOST_SB_SIGNING_UTILS_COPY_KEYS

$(eval $(host-autotools-package))
