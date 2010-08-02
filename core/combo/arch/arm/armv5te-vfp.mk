# At the moment, use the same settings than the one
# for armv5te, since TARGET_ARCH_VARIANT := armv5te-vfp
# will only be used to select an optimized VFP-capable assembly
# interpreter loop for Dalvik.
#
include $(BUILD_COMBOS)/arch/arm/armv5te.mk

ARCH_ARM_HAVE_VFP               := true

arch_variant_cflags := \
    -march=armv5te \
    -mtune=xscale \
    -mfloat-abi=softfp \
    -mfpu=vfp \
    -D__ARM_ARCH_5__ \
    -D__ARM_ARCH_5T__ \
    -D__ARM_ARCH_5E__ \
    -D__ARM_ARCH_5TE__

