###########################################################
## Standard rules for building a static library for the host.
##
## Additional inputs from base_rules.make:
## None.
##
## LOCAL_MODULE_SUFFIX will be set for you.
###########################################################

ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := .a
endif
ifneq ($(strip $(LOCAL_MODULE_STEM)$(LOCAL_BUILT_MODULE_STEM)),)
$(error $(LOCAL_PATH): Cannot set module stem for a library)
endif
LOCAL_UNINSTALLABLE_MODULE := true

$(call host-static-library-hook)

skip_build_from_source :=
ifdef LOCAL_PREBUILT_MODULE_FILE
ifeq (,$(call if-build-from-source,$(LOCAL_MODULE),$(LOCAL_PATH)))
prebuilt_is_cached := true
include $(BUILD_SYSTEM)/prebuilt_internal.mk
prebuilt_is_cached :=
skip_build_from_source := true
endif
endif

ifndef skip_build_from_source

include $(BUILD_SYSTEM)/binary.mk

$(LOCAL_BUILT_MODULE) : PRIVATE_INTERMEDIATES_DIR := $(intermediates)
$(LOCAL_BUILT_MODULE) : PRIVATE_CACHE_DIR := $(cache_dir)
$(LOCAL_BUILT_MODULE) : PRIVATE_MODULE_PATH := $(LOCAL_PATH)
$(LOCAL_BUILT_MODULE) : PRIVATE_MODULE_NAME := $(module_relative_name)
$(LOCAL_BUILT_MODULE) : PRIVATE_SRC_FILES := $(LOCAL_SRC_FILES)

$(LOCAL_BUILT_MODULE): $(built_whole_libraries)
$(LOCAL_BUILT_MODULE): $(all_objects)
	$(transform-host-o-to-static-lib)
	$(host-save-prebuilt-library)

endif  # skip_build_from_source
