
OP_IMAGE_TOOLS_VERSION = $(call qstrip,$(BR2_OP_IMAGE_TOOLS_VERSION))
OP_IMAGE_TOOLS_SITE ?= git@github.com:open-power/op-image-tools.git
OP_IMAGE_TOOLS_SITE_METHOD = git

OP_IMAGE_TOOLS_LICENSE = Apache-2.0
OP_IMAGE_TOOLS_DEPENDENCIES = host-python3

$(eval $(generic-package))
