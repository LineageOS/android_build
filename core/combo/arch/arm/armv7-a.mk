# Configuration for Linux on ARM.
# Generating binaries for the ARMv7-a architecture and higher
#
ARCH_ARM_HAVE_THUMB_SUPPORT     := true
ARCH_ARM_HAVE_FAST_INTERWORKING := true
ARCH_ARM_HAVE_64BIT_DATA        := true
ARCH_ARM_HAVE_HALFWORD_MULTIPLY := true
ARCH_ARM_HAVE_CLZ               := true
ARCH_ARM_HAVE_FFS               := true
ARCH_ARM_HAVE_ARMV7A            := true

ifeq ($(strip $(TARGET_ARCH_VARIANT_FPU)),)
ARCH_ARM_HAVE_VFP               := false
else
ARCH_ARM_HAVE_VFP               := true
endif

ifeq ($(strip $(TARGET_ARCH_VARIANT_FPU)),neon)
ARCH_ARM_HAVE_NEON              := true
endif

ifeq ($(strip $(TARGET_CPU_SMP)),true)
ARCH_ARM_HAVE_TLS_REGISTER      := true
endif

arch_variant_cflags := \
    -march=armv7-a \
    -mtune=$(strip $(TARGET_ARCH_VARIANT_CPU)) \
    -D__ARM_ARCH_7__ \
    -D__ARM_ARCH_7A__

ifeq ($(strip $(ARCH_ARM_HAVE_VFP)),true)
ifeq ($(strip $(ARCH_ARM_HAVE_NEON)),true)
arch_variant_cflags += -D__ARM_NEON__ -D__ARM_HAVE_NEON
else
arch_variant_cflags += -D__VFP_FP__ -D__ARM_HAVE_VFP
endif
arch_variant_cflags += -mfloat-abi=softfp -mfpu=$(strip $(TARGET_ARCH_VARIANT_FPU))
else
arch_variant_cflags += -mfloat-abi=soft
endif

ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a8)
arch_variant_ldflags := \
	-Wl,--fix-cortex-a8
else
arch_variant_ldflags :=
endif
