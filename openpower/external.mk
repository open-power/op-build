# OpenPower Toolchain
include $(sort $(wildcard $(BR2_EXTERNAL_OP_BUILD_PATH)/toolchain/*/*.mk))

# OpenPower Packages
include $(sort $(wildcard $(BR2_EXTERNAL_OP_BUILD_PATH)/package/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_OP_BUILD_PATH)/package/*/*.mk))

# Utilize user-defined custom directory.
include $(sort $(wildcard $(BR2_EXTERNAL_OP_BUILD_PATH)/custom/*.mk))
BR2_GLOBAL_PATCH_DIR += "$(BR2_EXTERNAL_OP_BUILD_PATH)/custom/patches"
