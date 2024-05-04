################################################################################
#
#  mlca_framework
#
################################################################################

#MLCA_FRAMEWORK_SITE ?= $(call github,open-power,mlca_framework,$(MLCA_FRAMEWORK_VERSION))
# Temporarily point to internal GHE repo until external repo is available
MLCA_FRAMEWORK_SITE ?= git@github.ibm.com:BHE/mlca_framework.git
MLCA_FRAMEWORK_SITE_METHOD = git

MLCA_FRAMEWORK_LICENSE = Apache-2.0
MLCA_FRAMEWORK_LICENSE_FILES = LICENSE
MLCA_FRAMEWORK_VERSION ?= 11ac6bd1ee9993005bc445ff550257cbfa79eaf1

HOST_MLCA_FRAMEWORK_DEPENDENCIES =

define HOST_MLCA_FRAMEWORK_BUILD_CMDS
	cd $(@D) && mkdir -p build && cd build && \
	cmake .. && ${MAKE}
endef

define HOST_MLCA_FRAMEWORK_INSTALL_CMDS
	cd $(@D) && \
    $(INSTALL) -m 0755 $(@D)/build/libmlca2_shared.so $(HOST_DIR)/usr/lib/ && \
	$(INSTALL) -m 0644 $(@D)/include/* $(HOST_DIR)/usr/include/
	$(INSTALL) -m 0644 $(@D)/qsc/crystals/crystals-oids.h $(HOST_DIR)/usr/include/
	$(INSTALL) -m 0644 $(@D)/qsc/crystals/pqalgs.h $(HOST_DIR)/usr/include/
endef

$(eval $(host-generic-package))
