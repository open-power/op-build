################################################################################
#
# pdata
#
################################################################################

PDATA_VERSION = $(call qstrip,$(BR2_PDATA_VERSION))
# TODO: WORKAROUND: Need to reenable next line and comment out the two lines
# after that, when code is propagated to a public repo
#PDATA_SITE = $(call github,phal,pdata,$(PDATA_VERSION))
PDATA_SITE = git@github.ibm.com:phal/pdata.git
PDATA_SITE_METHOD = git

PDATA_LICENSE = Apache-2.0
PDATA_LICENSE_FILES = $(@D)/LICENSE
PDATA_INSTALL_STAGING = YES
PDATA_INSTALL_TARGET = NO
PDATA_AUTORECONF = YES
PDATA_AUTORECONF_OPTS += -I $(HOST_DIR)/share/autoconf-archive
PDATA_DEPENDENCIES = ekb host-dtc machine-xml host-autoconf-archive

EKB_STAGING_DIR = $(STAGING_DIR)/ekb
MACHINE_XML_STAGING_DIR = $(STAGING_DIR)/openpower_mrw_scratch

TARGET_PROC =
ifeq ($(BR2_OPENPOWER_POWER10),y)
TARGET_PROC = p10
endif

QSTRIP_MACHINE_XML = $(call qstrip,$(BR2_OPENPOWER_MACHINE_XML_FILENAME))

PDATA_CONF_OPTS = --enable-gen_dynamicdt \
                  CHIP=$(TARGET_PROC) \

PDATA_MAKE_OPTS =  SYSTEM_NAME=$(call qstrip,$(BR2_OPENPOWER_CONFIG_NAME)) \
				   TARGET_PROC=$(TARGET_PROC) \
				   EKB=$(EKB_STAGING_DIR) \
				   SYSTEM_MRW_XML=$(MACHINE_XML_STAGING_DIR)/$(QSTRIP_MACHINE_XML) \

define PDATA_CREATE_M4_DIR
		mkdir -p $(@D)/m4
endef

PDATA_PRE_CONFIGURE_HOOKS += PDATA_CREATE_M4_DIR
$(eval $(autotools-package))
