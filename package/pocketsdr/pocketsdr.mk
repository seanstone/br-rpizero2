################################################################################
#
# pocketsdr
#
################################################################################

POCKETSDR_VERSION := 31729f5
POCKETSDR_SITE := https://github.com/seanstone/PocketSDR.git
POCKETSDR_SITE_METHOD := git
POCKETSDR_DEPENDENCIES += fftw-single libusb
POCKETSDR_GIT_SUBMODULES = YES
POCKETSDR_INSTALL_TARGET := YES

define POCKETSDR_BUILD_CMDS
	$(MAKE) WORKING_DIR=$(@D) CC="$(TARGET_CC)" CXX="$(TARGET_CXX)" LD="$(TARGET_LD)" -C $(@D) app-install
endef

define POCKETSDR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_scan $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_conf $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_dump $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_acq $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_trk $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/fftw_wisdom $(TARGET_DIR)/bin/
	$(INSTALL) -D -m 755 $(@D)/bin/pocket_snap $(TARGET_DIR)/bin/
endef

$(eval $(generic-package))
