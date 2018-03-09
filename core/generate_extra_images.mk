# This makefile is used to generate extra images for QCOM targets
# persist, device tree & NAND images required for different QCOM targets.

# These variables are required to make sure that the required
# files/targets are available before generating NAND images.
# This file is included from device/qcom/<TARGET>/AndroidBoard.mk
# and gets parsed before build/core/Makefile, which has these
# variables defined. build/core/Makefile will overwrite these
# variables again.
INSTALLED_USERDATAIMAGE_TARGET := $(PRODUCT_OUT)/userdata.img

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