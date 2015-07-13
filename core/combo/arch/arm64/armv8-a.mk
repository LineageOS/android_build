arch_variant_cflags :=

# If the chip uses a53 cores, enable the errata workarounds
ifeq ($(TARGET_2ND_CPU_VARIANT),cortex-a53)
    TARGET_CPU_CORTEX_A53 := true
else
# Enable the errata fixes for platforms that are known to need it
# in case BoardConfig doesn't declare a53
    # msm899x platforms need the errata workarounds
    ifneq ($(filter msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
        TARGET_CPU_CORTEX_A53 := true
    endif
    # 64bit exynos 7 octa need the errata workarounds
    ifneq ($(filter exynos5433 exynos7410 exynos7420,$(TARGET_SOC)),)
        TARGET_CPU_CORTEX_A53 := true
    endif
endif

# Leave the flag so devices that need the workaround but don't fit in
# either check above can still enable it.
ifeq ($(TARGET_CPU_CORTEX_A53),true)
arch_variant_ldflags := -Wl,--fix-cortex-a53-843419 \
                        -Wl,--fix-cortex-a53-835769
endif
