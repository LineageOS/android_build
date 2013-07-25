# Configuration for Linux on ARM.
# Generating binaries for the ARMv7-a architecture and higher
#
ARCH_ARM_HAVE_ARMV7A            := true
ifneq ($(strip $(TARGET_ARCH_VARIANT_FPU)),)
ARCH_ARM_HAVE_VFP               := true
else
ARCH_ARM_HAVE_VFP               := false
endif
ifeq ($(TARGET_ARCH_VARIANT_FPU), neon)
ARCH_ARM_HAVE_VFP_D32           := true
ARCH_ARM_HAVE_NEON              := true
endif

arch_variant_cflags := \
    -march=armv7-a

ifneq ($(strip $(TARGET_ARCH_VARIANT_CPU)),)
arch_variant_cflags += \
    -mtune=$(strip $(TARGET_ARCH_VARIANT_CPU))
endif

ifneq ($(strip $(TARGET_ARCH_VARIANT_FPU)),)
arch_variant_cflags += \
	-mfloat-abi=softfp \
	-mfpu=$(strip $(TARGET_ARCH_VARIANT_FPU))
else
# fall back on soft tunning if fpu is not specified
arch_variant_cflags += \
	-mfloat-abi=soft
endif

ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a8)
arch_variant_ldflags := \
	-Wl,--fix-cortex-a8
else
arch_variant_ldflags :=
endif
