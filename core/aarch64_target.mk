# Target-specific configuration
# aarch64 builds need some errata work around if using cortex-a53 cores
ifeq ($(TARGET_ARCH),true)
	# msm899x platforms need the errata fixes
	ifneq ($(filter msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
		TARGET_CPU_CORTEX_A53 := true
	endif
	# 64bit exynos 7 octa need the errata fixes
	ifneq ($(filter exynos5433 exynos7410 exynos7420,$(TARGET_SOC)),)
		TARGET_CPU_CORTEX_A53 := true
	endif
endif
