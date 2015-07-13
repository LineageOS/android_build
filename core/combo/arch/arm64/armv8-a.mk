arch_variant_cflags :=

# If the chip uses a53 cores, enable the errata workarounds
ifneq ($(filter $(TARGET_CPU_VARIANT) $(TARGET_2ND_CPU_VARIANT),cortex-a53),)
    TARGET_CPU_CORTEX_A53 := true
endif

# Leave the flag so devices that need the workaround but don't fit in
# the check above can still enable it.
ifeq ($(TARGET_CPU_CORTEX_A53),true)
arch_variant_ldflags := -Wl,--fix-cortex-a53-843419 \
                        -Wl,--fix-cortex-a53-835769
endif
