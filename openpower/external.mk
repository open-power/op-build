include $(sort $(wildcard $(BR2_EXTERNAL)/package/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*.mk))

# Utilize user-defined custom directory.
include $(sort $(wildcard $(BR2_EXTERNAL)/custom/*.mk))
BR2_GLOBAL_PATCH_DIR += "$(BR2_EXTERNAL)/custom/patches"
