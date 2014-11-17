# Target-specific configuration

# Populate the qcom hardware variants in the project pathmap.
define qcom-set-path-variant
$(call project-set-path-variant,qcom-$(2),TARGET_QCOM_$(1)_VARIANT,hardware/qcom/$(2))
endef

# Enable DirectTrack on QCOM legacy boards
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    TARGET_GLOBAL_CFLAGS += -DQCOM_HARDWARE
    TARGET_GLOBAL_CPPFLAGS += -DQCOM_HARDWARE

    TARGET_USES_QCOM_BSP := true
    TARGET_GLOBAL_CFLAGS += -DQCOM_BSP
    TARGET_GLOBAL_CPPFLAGS += -DQCOM_BSP

    TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

    # Enable DirectTrack for legacy targets
    ifneq ($(filter msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
    ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
        TARGET_GLOBAL_CFLAGS += -DQCOM_DIRECTTRACK
        TARGET_GLOBAL_CPPFLAGS += -DQCOM_DIRECTTRACK
    endif
    endif

$(call project-set-path,qcom-audio,hardware/qcom/audio-caf/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,CAMERA,camera)
$(call project-set-path,qcom-display,hardware/qcom/display-caf/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,GPS,gps)
$(call project-set-path,qcom-media,hardware/qcom/media-caf/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,SENSORS,sensors)
else
$(call project-set-path,qcom-audio,hardware/qcom/audio/default)
$(call qcom-set-path-variant,CAMERA,camera)
$(call project-set-path,qcom-display,hardware/qcom/display/$(TARGET_BOARD_PLATFORM))
$(call qcom-set-path-variant,GPS,gps)
$(call project-set-path,qcom-media,hardware/qcom/media/default)
$(call qcom-set-path-variant,SENSORS,sensors)
endif
