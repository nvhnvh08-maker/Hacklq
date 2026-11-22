# Makefile cho TrbaoMod VIP - Liên Quân Mobile
# Tác giả: by trbaomod

TARGET = iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TrbaoModVIP

TrbaoModVIP_FILES = TrbaoFloatingButton.m TrbaoModViewController.m TrbaoShareMapManager.m TrbaoModHooks.m
TrbaoModVIP_CFLAGS = -fobjc-arc -O2 -I.
TrbaoModVIP_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
