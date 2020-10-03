################################################################################
#
# pdata
#
################################################################################

PDATA_VERSION = $(call qstrip,$(BR2_PDATA_VERSION))
ifeq ($(BR2_PDATA_GITHUB_PROJECT),y)
# after that, when code is propagated to a public repo
#PDATA_SITE = $(call github,phal,pdata,$(PDATA_VERSION))
PDATA_SITE = git@github.ibm.com:phal/pdata.git
PDATA_SITE_METHOD = git
else ifeq ($(BR2_PDATA_CUSTOM_GIT),y)
PDATA_SITE = $(BR2_PDATA_CUSTOM_GIT_VALUE)
PDATA_SITE_METHOD = git
endif

PDATA_LICENSE = Apache-2.0
PDATA_LICENSE_FILES = $(@D)/LICENSE
PDATA_INSTALL_STAGING = YES
PDATA_INSTALL_TARGET = NO
PDATA_AUTORECONF = YES
PDATA_AUTORECONF_OPTS += -I $(HOST_DIR)/share/autoconf-archive
PDATA_DEPENDENCIES = ekb host-dtc host-autoconf-archive

EKB_STAGING_DIR = $(STAGING_DIR)/ekb
MACHINE_XML_STAGING_DIR = $(STAGING_DIR)/openpower_mrw_scratch

TARGET_PROC =
ifeq ($(BR2_OPENPOWER_POWER10),y)
TARGET_PROC = p10
endif

ifeq ($(BR2_PACKAGE_OPENPOWER_PNOR_P10),y)
PDATA_DEPENDENCIES += $(call qstrip,$(BR2_OPENPOWER_P10_XMLS))
QSTRIP_MACHINE_XMLS = $(call qstrip,$(foreach xml,$(BR2_OPENPOWER_P10_XMLS),$(MACHINE_XML_STAGING_DIR)/$(BR2_$(call UPPERCASE,$(call qstrip,$(xml)))_FILENAME)))
else
PDATA_DEPENDENCIES += machine-xml
QSTRIP_MACHINE_XMLS = $(call qstrip,$(MACHINE_XML_STAGING_DIR)/$(BR2_OPENPOWER_MACHINE_XML_FILENAME))
endif

PDATA_CONF_OPTS = --enable-gen_dynamicdt CHIP=$(TARGET_PROC)

PDATA_MAKE_OPTS = EKB=$(EKB_STAGING_DIR) \
                  SYSTEMS_MRW_XML="$(QSTRIP_MACHINE_XMLS)"

define PDATA_CREATE_M4_DIR
		mkdir -p $(@D)/m4
endef

PDATA_PRE_CONFIGURE_HOOKS += PDATA_CREATE_M4_DIR
$(eval $(autotools-package))
