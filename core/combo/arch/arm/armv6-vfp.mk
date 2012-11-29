# Configuration for Linux on ARM.
# Generating binaries for the ARMv6k+VFP architecture and higher
#
ARCH_ARM_HAVE_THUMB_SUPPORT     := true
ARCH_ARM_HAVE_FAST_INTERWORKING := true
ARCH_ARM_HAVE_64BIT_DATA        := true
ARCH_ARM_HAVE_HALFWORD_MULTIPLY := true
ARCH_ARM_HAVE_CLZ               := true
ARCH_ARM_HAVE_FFS               := true
ARCH_ARM_HAVE_VFP               := true

# Note: Hard coding the 'tune' value here is probably not ideal,
# and a better solution should be found in the future.
#
arch_variant_cflags := \
    -march=armv6k \
    -mtune=arm1136j-s  \
    -D__ARM_ARCH_6__ \
    -D__ARM_ARCH_6J__ \
    -D__ARM_ARCH_6K__
