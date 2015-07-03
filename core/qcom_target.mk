# Target-specific configuration

# Populate the qcom hardware variants in the project pathmap.
define qcom-set-path-variant
$(call project-set-path-variant,qcom-$(2),TARGET_QCOM_$(1)_VARIANT,hardware/qcom/$(2))
endef
define ril-set-path-variant
$(call project-set-path-variant,ril,TARGET_RIL_VARIANT,hardware/$(1))
endef
define gps-hal-set-path-variant
$(call project-set-path-variant,gps-hal,TARGET_GPS_HAL_PATH,$(1))
endef
define loc-api-set-path-variant
$(call project-set-path-variant,loc-api,TARGET_LOC_API_PATH,$(1))
endef
define keymaster-set-path-variant
$(call project-set-path-variant,keymaster,TARGET_KEYMASTER_PATH,$(1))
endef

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    qcom_flags := -DQCOM_HARDWARE
    qcom_flags += -DQCOM_BSP

    TARGET_USES_QCOM_BSP := true
    TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

    # Enable DirectTrack for legacy targets
    ifneq ($(filter msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            qcom_flags += -DQCOM_DIRECTTRACK
        endif
        # Enable legacy graphics functions
        qcom_flags += -DQCOM_BSP_LEGACY
    endif

    # Enable extra offloading for post-805 targets
    ifneq ($(filter msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
        qcom_flags += -DHAS_EXTRA_FLAC_METADATA
    endif

    TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)
    CLANG_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    CLANG_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)

    # Multiarch needs these too..
    2ND_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    2ND_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)
    2ND_CLANG_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    2ND_CLANG_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)

$(call project-set-path,qcom-audio,hardware/qcom/audio-caf/$(TARGET_BOARD_PLATFORM))
ifeq ($(USE_DEVICE_SPECIFIC_CAMERA),true)
$(call project-set-path,qcom-camera,$(TARGET_DEVICE_DIR)/camera)
else
$(call qcom-set-path-variant,CAMERA,camera)
endif
$(call project-set-path,qcom-display,hardware/qcom/display-caf/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,GPS,gps)
$(call project-set-path,qcom-media,hardware/qcom/media-caf/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,SENSORS,sensors)
$(call ril-set-path-variant,ril)
$(call loc-api-set-path-variant,vendor/qcom/opensource/location)
$(call gps-hal-set-path-variant,hardware/qcom/gps)
ifneq ($(filter msm8960 msm8974 msm8226 msm8610 msm8084 apq8084 msm8916 msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
$(call keymaster-set-path-variant,hardware/qcom/keymaster)
endif
else
$(call project-set-path,qcom-audio,hardware/qcom/audio/default)
$(call qcom-set-path-variant,CAMERA,camera)
$(call project-set-path,qcom-display,hardware/qcom/display/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,GPS,gps)
$(call project-set-path,qcom-media,hardware/qcom/media/default)
$(call qcom-set-path-variant,SENSORS,sensors)
$(call ril-set-path-variant,ril)
$(call loc-api-set-path-variant,vendor/qcom/opensource/location)
$(call gps-hal-set-path-variant,hardware/qcom/gps)
endif
