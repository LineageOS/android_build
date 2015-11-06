#----------------------------------------------------------------------
# Generate device tree image (dt.img)
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_CUSTOM_BOOTIMG_MK)),)
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DT)),true)
ifneq ($(strip $(BOARD_KERNEL_PREBUILT_DT)),true)
ifeq ($(strip $(BUILD_TINY_ANDROID)),true)
include device/qcom/common/dtbtool/Android.mk
endif

ifeq ($(strip $(TARGET_CUSTOM_DTBTOOL)),)
DTBTOOL_NAME := dtbToolCM
else
DTBTOOL_NAME := $(TARGET_CUSTOM_DTBTOOL)
endif

DTBTOOL := $(HOST_OUT_EXECUTABLES)/$(DTBTOOL_NAME)$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

possible_dtb_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts/ $(KERNEL_OUT)/arch/arm/boot/
dtb_dir = $(firstword $(wildcard $(possible_dtb_dirs)))

define build-dtimage-target
    $(call pretty,"Target dt image: $@")
    $(hide) $(DTBTOOL) $(BOARD_DTBTOOL_ARGS) -o $@ -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ $(dtb_dir)
    $(hide) chmod a+r $@
endef

$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(INSTALLED_KERNEL_TARGET)
	$(build-dtimage-target)
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_DTIMAGE_TARGET)
ALL_MODULES.$(LOCAL_MODULE).INSTALLED += $(INSTALLED_DTIMAGE_TARGET)
endif
endif
endif
