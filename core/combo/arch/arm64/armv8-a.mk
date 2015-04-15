arch_variant_cflags :=

ifeq ($(TARGET_CPU_CORTEX_A53),true)
arch_variant_ldflags := -Wl,--fix-cortex-a53-835769
endif
