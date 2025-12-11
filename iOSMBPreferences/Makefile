ARCHS = arm64 arm64e

TARGET := iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = iOSMB-Server

iOSMB-Server_FILES = iOSMBRootListController.m
iOSMB-Server_FRAMEWORKS = UIKit
iOSMB-Server_PRIVATE_FRAMEWORKS = Preferences
iOSMB-Server_INSTALL_PATH = /Library/PreferenceBundles
iOSMB-Server_CFLAGS = -fobjc-arc
iOSMB-Server_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/bundle.mk
