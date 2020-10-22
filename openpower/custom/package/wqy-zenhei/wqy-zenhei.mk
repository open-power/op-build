################################################################################
#
# wqy-zenhei
#
################################################################################

WQY_ZENHEI_VERSION = 0.9.45
WQY_ZENHEI_SITE = https://downloads.sourceforge.net/project/wqy/wqy-zenhei/$(WQY_ZENHEI_VERSION)%20%28Fighting-state%20RC1%29
WQY_ZENHEI_TARGET_DIR = $(TARGET_DIR)/usr/share/fonts/wqy-zenhei
WQY_ZENHEI_LICENSE =  GPL-v2
WQY_ZENHEI_LICENSE_FILES = COPYING

define WQY_ZENHEI_INSTALL_TARGET_CMDS
	mkdir -p $(WQY_ZENHEI_TARGET_DIR)
	$(INSTALL) -m 644 $(@D)/wqy-zenhei.ttc $(WQY_ZENHEI_TARGET_DIR)
	$(INSTALL) -D -m 0644 $(@D)/43-wqy-zenhei-sharp.conf \
	    $(TARGET_DIR)/usr/share/fontconfig/conf.avail/43-wqy-zenhei-sharp.conf
	$(INSTALL) -D -m 0644 $(@D)/44-wqy-zenhei.conf \
	    $(TARGET_DIR)/usr/share/fontconfig/conf.avail/44-wqy-zenhei.conf

endef

$(eval $(generic-package))
