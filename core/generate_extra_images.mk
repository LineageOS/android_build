# This makefile is used to generate extra images for QCOM targets
# persist, device tree & NAND images required for different QCOM targets.

# These variables are required to make sure that the required
# files/targets are available before generating NAND images.
# This file is included from device/qcom/<TARGET>/AndroidBoard.mk
# and gets parsed before build/core/Makefile, which has these
# variables defined. build/core/Makefile will overwrite these
# variables again.
INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
INSTALLED_USERDATAIMAGE_TARGET := $(PRODUCT_OUT)/userdata.img

#----------------------------------------------------------------------
# Generate secure boot & recovery image
#----------------------------------------------------------------------
ifeq ($(TARGET_BOOTIMG_SIGNED),true)
INSTALLED_SEC_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img.secure
INSTALLED_SEC_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img.secure

ifneq ($(BUILD_TINY_ANDROID),true)
intermediates := $(call intermediates-dir-for,PACKAGING,recovery_patch)
RECOVERY_FROM_BOOT_PATCH := $(intermediates)/recovery_from_boot.p
endif

ifndef TARGET_SHA_TYPE
  TARGET_SHA_TYPE := sha256
endif

define build-sec-image
	$(hide) mv -f $(1) $(1).nonsecure
	$(hide) openssl dgst -$(TARGET_SHA_TYPE) -binary $(1).nonsecure > $(1).$(TARGET_SHA_TYPE)
	$(hide) openssl rsautl -sign -in $(1).$(TARGET_SHA_TYPE) -inkey $(PRODUCT_PRIVATE_KEY) -out $(1).sig
	$(hide) dd if=/dev/zero of=$(1).sig.padded bs=$(BOARD_KERNEL_PAGESIZE) count=1
	$(hide) dd if=$(1).sig of=$(1).sig.padded conv=notrunc
	$(hide) cat $(1).nonsecure $(1).sig.padded > $(1).secure
	$(hide) rm -rf $(1).$(TARGET_SHA_TYPE) $(1).sig $(1).sig.padded
	$(hide) mv -f $(1).secure $(1)
endef

$(INSTALLED_SEC_BOOTIMAGE_TARGET): $(INSTALLED_BOOTIMAGE_TARGET) $(RECOVERY_FROM_BOOT_PATCH)
	$(hide) $(call build-sec-image,$(INSTALLED_BOOTIMAGE_TARGET))

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_SEC_BOOTIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_SEC_BOOTIMAGE_TARGET)

$(INSTALLED_SEC_RECOVERYIMAGE_TARGET): $(INSTALLED_RECOVERYIMAGE_TARGET) $(RECOVERY_FROM_BOOT_PATCH)
	$(hide) $(call build-sec-image,$(INSTALLED_RECOVERYIMAGE_TARGET))

ifneq ($(BUILD_TINY_ANDROID),true)
ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_SEC_RECOVERYIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_SEC_RECOVERYIMAGE_TARGET)
endif # !BUILD_TINY_ANDROID
endif # TARGET_BOOTIMG_SIGNED

#----------------------------------------------------------------------
# Generate persist image (persist.img)
#----------------------------------------------------------------------
TARGET_OUT_PERSIST := $(PRODUCT_OUT)/persist

INTERNAL_PERSISTIMAGE_FILES := \
	$(filter $(TARGET_OUT_PERSIST)/%,$(ALL_DEFAULT_INSTALLED_MODULES))

INSTALLED_PERSISTIMAGE_TARGET := $(PRODUCT_OUT)/persist.img

define build-persistimage-target
    $(call pretty,"Target persist fs image: $(INSTALLED_PERSISTIMAGE_TARGET)")
    @mkdir -p $(TARGET_OUT_PERSIST)
    $(hide) $(MKEXTUSERIMG) -s $(TARGET_OUT_PERSIST) $@ ext4 persist $(BOARD_PERSISTIMAGE_PARTITION_SIZE)
    $(hide) chmod a+r $@
    $(hide) $(call assert-max-image-size,$@,$(BOARD_PERSISTIMAGE_PARTITION_SIZE),yaffs)
endef

$(INSTALLED_PERSISTIMAGE_TARGET): $(MKEXTUSERIMG) $(MAKE_EXT4FS) $(INTERNAL_PERSISTIMAGE_FILES)
	$(build-persistimage-target)

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_PERSISTIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_PERSISTIMAGE_TARGET)

#----------------------------------------------------------------------
# Generate extra userdata images (for variants with multiple mmc sizes)
#----------------------------------------------------------------------
ifneq ($(BOARD_USERDATAEXTRAIMAGE_PARTITION_SIZE),)

ifndef BOARD_USERDATAEXTRAIMAGE_PARTITION_NAME
  BOARD_USERDATAEXTRAIMAGE_PARTITION_NAME := extra
endif

BUILT_USERDATAEXTRAIMAGE_TARGET := $(PRODUCT_OUT)/userdata_$(BOARD_USERDATAEXTRAIMAGE_PARTITION_NAME).img

define build-userdataextraimage-target
    $(call pretty,"Target EXTRA userdata fs image: $(INSTALLED_USERDATAEXTRAIMAGE_TARGET)")
    @mkdir -p $(TARGET_OUT_DATA)
    $(hide) $(MKEXTUSERIMG) -s $(TARGET_OUT_DATA) $@ ext4 data $(BOARD_USERDATAEXTRAIMAGE_PARTITION_SIZE)
    $(hide) chmod a+r $@
    $(hide) $(call assert-max-image-size,$@,$(BOARD_USERDATAEXTRAIMAGE_PARTITION_SIZE),yaffs)
endef

INSTALLED_USERDATAEXTRAIMAGE_TARGET := $(BUILT_USERDATAEXTRAIMAGE_TARGET)
$(INSTALLED_USERDATAEXTRAIMAGE_TARGET): $(INSTALLED_USERDATAIMAGE_TARGET)
	$(build-userdataextraimage-target)

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_USERDATAEXTRAIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_USERDATAEXTRAIMAGE_TARGET)

endif

.PHONY: aboot
aboot: $(INSTALLED_BOOTLOADER_MODULE)

.PHONY: sec_bootimage
sec_bootimage: $(INSTALLED_BOOTIMAGE_TARGET) $(INSTALLED_SEC_BOOTIMAGE_TARGET)

.PHONY: sec_recoveryimage
sec_recoveryimage: $(INSTALLED_RECOVERYIMAGE_TARGET) $(INSTALLED_SEC_RECOVERYIMAGE_TARGET)

.PHONY: persistimage
persistimage: $(INSTALLED_PERSISTIMAGE_TARGET)
