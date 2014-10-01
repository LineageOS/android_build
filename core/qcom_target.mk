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
    qcom_variant_list := audio camera display gps media sensors

    # Set the QCOM_*_PATH variables for each variant.
    #   $1 = Upper case name for variable name
    #   $2 = Lower case name for variable value (pathname)
    define qcom_variant_path
    $(strip \
        $(if $(TARGET_QCOM_$(1)_VARIANT), \
            hardware/qcom/$(2)-$(TARGET_QCOM_$(1)_VARIANT), \
            hardware/qcom/$(2)))
    endef
    $(foreach variant, \
        $(qcom_variant_list), \
        $(eval ln:=$(shell echo $(variant) | tr [A-Z] [a-z])) \
        $(eval un:=$(shell echo $(variant) | tr [a-z] [A-Z])) \
        $(eval QCOM_$(un)_PATH:=$(call qcom_variant_path,$(un),$(ln))))

endif
