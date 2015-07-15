arch_variant_cflags :=

ifdef TARGET_2ND_ARCH
  ifneq (,$(filter $(TARGET_$(TARGET_2ND_ARCH_VAR_PREFIX)CPU_VARIANT),cortex-a53))
    TARGET_CPU_CORTEX_A53 ?= true
  endif
else
  ifneq (,$(filter $(TARGET_CPU_VARIANT),cortex-a53))
    TARGET_CPU_CORTEX_A53 ?= true
  endif
endif

ifeq ($(TARGET_CPU_CORTEX_A53),true)
arch_variant_ldflags := -Wl,--fix-cortex-a53-843419 \
                        -Wl,--fix-cortex-a53-835769
endif
