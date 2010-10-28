#
# Copyright (C) 2009 The Android-x86 Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

ifeq ($(TARGET_PREBUILT_KERNEL),)

ifeq ($(TARGET_ARCH),x86)
KERNEL_TARGET := bzImage
TARGET_KERNEL_CONFIG ?= android-x86_defconfig
endif
ifeq ($(TARGET_ARCH),arm)
KERNEL_TARGET := zImage
TARGET_KERNEL_CONFIG ?= goldfish_defconfig
endif

KBUILD_OUTPUT := $(CURDIR)/$(TARGET_OUT_INTERMEDIATES)/kernel
mk_kernel := + $(hide) $(MAKE) -C $(TARGET_KERNEL_DIR) O=$(KBUILD_OUTPUT) ARCH=$(TARGET_ARCH) $(if $(SHOW_COMMANDS),V=1)
ifneq ($(TARGET_ARCH),$(HOST_ARCH))
mk_kernel += INSTALL_MOD_STRIP=1
mk_kernel += CROSS_COMPILE=$(CURDIR)/$(TARGET_TOOLS_PREFIX)
endif

ifneq ($(wildcard $(TARGET_KERNEL_CONFIG)),)
KERNEL_CONFIG_FILE := $(TARGET_KERNEL_CONFIG)
else
KERNEL_CONFIG_FILE := $(TARGET_KERNEL_DIR)/arch/$(TARGET_ARCH)/configs/$(TARGET_KERNEL_CONFIG)
endif
MOD_ENABLED := $(shell grep ^CONFIG_MODULES=y $(KERNEL_CONFIG_FILE))
FIRMWARE_ENABLED := $(shell grep ^CONFIG_FIRMWARE_IN_KERNEL=y $(KERNEL_CONFIG_FILE))

# I understand Android build system discourage to use submake,
# but I don't want to write a complex Android.mk to build kernel.
# This is the simplest way I can think.
KERNEL_DOTCONFIG_FILE := $(KBUILD_OUTPUT)/.config
$(KERNEL_DOTCONFIG_FILE): $(KERNEL_CONFIG_FILE) | $(ACP)
	$(copy-file-to-new-target)

ifeq ($(HOST_OS),darwin)
DARWIN_ELF_H_SOURCE := external/elfutils/libelf/elf.h
DARWIN_ELF_H := $(KBUILD_OUTPUT)/scripts/mod/elf.h
$(DARWIN_ELF_H): $(DARWIN_ELF_H_SOURCE) | $(ACP)
	$(copy-file-to-new-target)
endif

BUILT_KERNEL_TARGET := $(KBUILD_OUTPUT)/arch/$(TARGET_ARCH)/boot/$(KERNEL_TARGET)
.PHONY: _zimage
_zimage: $(KERNEL_DOTCONFIG_FILE) $(DARWIN_ELF_H)
	@echo "**** BUILDING KERNEL ****"
	$(mk_kernel) oldconfig
	$(mk_kernel) $(KERNEL_TARGET) $(if $(MOD_ENABLED),modules)

.PHONY: _modules
_modules: _zimage
ifeq ($(TARGET_PREBUILT_MODULES),)
	@echo "**** BUILDING MODULES ****"
	$(hide) rm -rf $(TARGET_OUT)/lib/modules
	$(if $(MOD_ENABLED),$(mk_kernel) INSTALL_MOD_PATH=$(CURDIR)/$(TARGET_OUT) modules_install)
	$(hide) rm -f $(TARGET_OUT)/lib/modules/*/{build,source}
else
	$(hide) $(ACP) -r $(TARGET_PREBUILT_MODULES) $(TARGET_OUT)/lib	
endif

	$(if $(FIRMWARE_ENABLED),$(mk_kernel) INSTALL_MOD_PATH=$(CURDIR)/$(TARGET_OUT) firmware_install)

.PHONY: _wifi
_wifi: _modules
ifneq ($(TARGET_NO_BUILD_WIFI),true)
	@echo "**** BUILDING WIFI ****"
ifneq ($(MOD_ENABLED),)
	@echo "Copying $(shell ls $(CURDIR)/$(TARGET_OUT)/lib/modules/*/kernel/drivers/net/wireless/*/*.ko) -> $(CURDIR)/$(TARGET_OUT)/lib/modules/$(notdir $(shell ls $(CURDIR)/$(TARGET_OUT)/lib/modules/*/kernel/drivers/net/wireless/*/*.ko))"
	$(hide) cp $(shell ls $(CURDIR)/$(TARGET_OUT)/lib/modules/*/kernel/drivers/net/wireless/*/*.ko) $(CURDIR)/$(TARGET_OUT)/lib/modules/$(notdir $(shell ls $(CURDIR)/$(TARGET_OUT)/lib/modules/*/kernel/drivers/net/wireless/*/*.ko))
endif
endif

$(INSTALLED_KERNEL_TARGET): _wifi
	@echo "**** KERNEL BUILT ****"
	$(hide) $(ACP) -fp $(BUILT_KERNEL_TARGET) $@

installclean: FILES += $(KBUILD_OUTPUT) $(INSTALLED_KERNEL_TARGET)

TARGET_PREBUILT_KERNEL  := $(INSTALLED_KERNEL_TARGET)

.PHONY: kernel
kernel: $(TARGET_PREBUILT_KERNEL)

else

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	@echo "Transforming $(INSTALLED_KERNEL_TARGET) to $(TARGET_PREBUILT_KERNEL)"
	$(transform-prebuilt-to-target)

endif # TARGET_PREBUILT_KERNEL

ifeq ($(TARGET_PREBUILT_RECOVERY_KERNEL),)

$(INSTALLED_RECOVERY_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
	@echo "Transforming $(INSTALLED_RECOVERY_KERNEL_TARGET) to $(TARGET_PREBUILT_KERNEL)"
	$(transform-prebuilt-to-target)

else

$(INSTALLED_RECOVERY_KERNEL_TARGET): $(TARGET_PREBUILT_RECOVERY_KERNEL) | $(ACP)
	@echo "Transforming $(INSTALLED_RECOVERY_KERNEL_TARGET) to $(TARGET_PREBUILT_RECOVERY_KERNEL)"
	$(transform-prebuilt-to-target)

endif
