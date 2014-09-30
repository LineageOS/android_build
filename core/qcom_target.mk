# Target-specific configuration

# Enable DirectTrack on QCOM legacy boards
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    TARGET_GLOBAL_CFLAGS += -DQCOM_HARDWARE
    TARGET_GLOBAL_CPPFLAGS += -DQCOM_HARDWARE

    ifeq ($(TARGET_USES_QCOM_BSP),true)
        TARGET_GLOBAL_CFLAGS += -DQCOM_BSP
        TARGET_GLOBAL_CPPFLAGS += -DQCOM_BSP
    endif

    # Enable DirectTrack for legacy targets
    ifneq ($(filter caf bfam,$(TARGET_QCOM_AUDIO_VARIANT)),)
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            TARGET_GLOBAL_CFLAGS += -DQCOM_DIRECTTRACK
            TARGET_GLOBAL_CPPFLAGS += -DQCOM_DIRECTTRACK
        endif
    endif

# This is the list of all supported QCOM variants.
QCOM_VARIANTS := audio camera display gps media sensors

# Set QCOM_XX_PATH values based on variant
$(strip \
    $(foreach v, $(QCOM_VARIANTS), \
        $(eval _uv := $(call uppercase, $(v))) \
        $(eval QCOM_$(_uv)_PATH := \
            $(if $(TARGET_QCOM_$(_uv)_VARIANT), \
                hardware/qcom/$(v)-$(TARGET_QCOM_$(_uv)_VARIANT), \
                hardware/qcom/$(v)))))

endif
