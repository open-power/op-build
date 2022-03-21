################################################################################
#
# fsp_trace
#
################################################################################

FSP_TRACE_VERSION = $(call qstrip,$(BR2_FSP_TRACE_VERSION))
FSP_TRACE_SITE ?= $(call github,open-power,fsp-trace,$(FSP_TRACE_VERSION))

FSP_TRACE_LICENSE = Apache-2.0
FSP_TRACE_LICENSE_FILES = LICENSE

FSP_TRACE_INSTALL_IMAGES = YES
FSP_TRACE_INSTALL_TARGET = NO

define FSP_TRACE_BUILD_CMDS
        bash -c 'cd $(@D) && $(MAKE)'
endef

define FSP_TRACE_INSTALL_IMAGES_CMDS
    mkdir -p $(STAGING_DIR)/fsp-trace/
    $(INSTALL) -D $(@D)/fsp-trace $(STAGING_DIR)/fsp-trace/
endef


$(eval $(generic-package))
