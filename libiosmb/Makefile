ARCHS = arm64 arm64e

TARGET := iphone:clang:latest:12.0
INSTALL_TARGET_PROCESSES = MobileSMS SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = libiosmb

libiosmb_FILES = Tweak.x
libiosmb_CFLAGS = -fobjc-arc
libiosmb_LIBRARIES = mryipc c++
libiosmb_LDFLAGS = -lc++

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
		install.exec "killall -9 imagent"

