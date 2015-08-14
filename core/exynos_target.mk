# Target-specific configuration

# Populate the Exynos hardware variants in the project pathmap.
$(call project-set-path,exynos-soc,hardware/samsung_slsi/$(TARGET_SOC))
ifeq ($(TARGET_SLSI_VARIANT),)
$(call project-set-path,exynos-platform,hardware/samsung_slsi/$(TARGET_BOARD_PLATFORM))
else
$(call project-set-path,exynos-platform,hardware/samsung_slsi/$(TARGET_BOARD_PLATFORM)-$(TARGET_SLSI_VARIANT))
endif
