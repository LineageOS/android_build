# Target-specific configuration
# aarch64 builds need some errata work around if using cortex-a53 cores
ifeq ($(TARGET_ARCH),arm64)
    # If the chip uses a53 cores, enable the errata fixes
    ifeq ($(TARGET_2ND_CPU_VARIANT),cortex-a53)
        TARGET_CPU_CORTEX_A53 := true
    else
    # Enable the errata fixes for platforms that are known to need it
    # in case BoardConfig doesn't declare a53
        # msm899x platforms need the errata fixes
        ifneq ($(filter msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
            TARGET_CPU_CORTEX_A53 := true
        endif
        # 64bit exynos 7 octa need the errata fixes
        ifneq ($(filter exynos5433 exynos7410 exynos7420,$(TARGET_SOC)),)
            TARGET_CPU_CORTEX_A53 := true
        endif
    endif
endif
