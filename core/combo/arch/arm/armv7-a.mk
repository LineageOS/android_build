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
ARCH_ARM_HAVE_VFP_D32           := true
ARCH_ARM_HAVE_NEON              := true
endif

ifeq ($(strip $(TARGET_CPU_SMP)),true)
ARCH_ARM_HAVE_TLS_REGISTER      := true
endif

# We don't really need the following tests for checking
# whether the compiler supports a given mcpu argument since
# we include our own cross compiler, but it makes it easier to
# maintain when we change the compiler.

mcpu-arg = $(shell sed 's/^-mcpu=//' <<< "$(call cc-option,-mcpu=$(1),-mcpu=$(2))")

ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a15)
	TARGET_ARCH_VARIANT_CPU := $(call mcpu-arg,cortex-a15,cortex-a9)
endif
ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a9)
	TARGET_ARCH_VARIANT_CPU := $(call mcpu-arg,cortex-a9,cortex-a8)
endif
ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a8)
	TARGET_ARCH_VARIANT_CPU := $(call mcpu-arg,cortex-a8,)
endif


ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),)
arch_variant_cflags := \
    -march=armv7-a
else
arch_variant_cflags := \
    -mcpu=$(strip $(TARGET_ARCH_VARIANT_CPU)) \
    -mtune=$(strip $(TARGET_ARCH_VARIANT_CPU))
endif

ifeq ($(strip $(ARCH_ARM_HAVE_VFP)),true)
arch_variant_cflags += \
	-mfloat-abi=softfp \
	-mfpu=$(strip $(TARGET_ARCH_VARIANT_FPU))
else
arch_variant_cflags += \
	-mfloat-abi=soft
endif

arch_variant_cflags += \
    -D__ARM_ARCH_7__ \
    -D__ARM_ARCH_7A__

ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),cortex-a8)
arch_variant_ldflags := \
	-Wl,--fix-cortex-a8
else
arch_variant_ldflags :=
endif
