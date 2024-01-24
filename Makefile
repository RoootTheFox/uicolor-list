TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = uicolors

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = uicolors

$(APPLICATION_NAME)_FILES = main.m UICDBGAppDelegate.m UICDBGRootViewController.m
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics
$(APPLICATION_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
