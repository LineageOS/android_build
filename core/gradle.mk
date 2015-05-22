#
# Copyright (C) 2015 Cyanogen, Inc.
#

ifeq ($(strip $(LOCAL_MODULE_CLASS)),APPS)
  output_extension := $(COMMON_ANDROID_PACKAGE_SUFFIX)
else ifeq ($(strip $(LOCAL_MODULE_CLASS)),JAVA_LIBRARIES)
  output_extension := $(COMMON_JAVA_PACKAGE_SUFFIX)
else ifeq ($(strip $(LOCAL_MODULE_CLASS)),ANDROID_LIBRARIES)
  output_extension := .aar
  LOCAL_MODULE_CLASS := JAVA_LIBRARIES
else
  $(error Must set LOCAL_MODULE_CLASS)
endif

ifeq ($(strip $(LOCAL_GRADLE_PROJECT_DIR)),)
  LOCAL_GRADLE_PROJECT_DIR := $(LOCAL_PATH)
endif
ifeq ($(strip $(LOCAL_GRADLE_BUILD_FILE)),)
  LOCAL_GRADLE_BUILD_FILE := build.gradle
endif
ifeq ($(strip $(LOCAL_GRADLE_SUBPROJECT)),)
  LOCAL_GRADLE_SUBPROJECT := :
endif

LOCAL_GRADLE_FLAVORS += $(TARGET_BUILD_TYPE)

gradle_module := $(lastword $(subst :,$(space),$(LOCAL_GRADLE_SUBPROJECT)))
ifeq ($(strip $(gradle_module)),)
  gradle_module := $(lastword $(subst /,$(space),$(abspath $(LOCAL_GRADLE_PROJECT_DIR))))
endif

task_flavors := $(subst $(space),,$(foreach flavor,$(LOCAL_GRADLE_FLAVORS),$(call capitalize,$(flavor))))
output_flavors := $(subst $(space),,$(foreach flavor,$(LOCAL_GRADLE_FLAVORS),-$(call lowercase,$(flavor))))
output_filename := $(gradle_module)$(output_flavors)$(output_extension)

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/outputs/$(subst .,,$(output_extension))/$(output_filename)

$(LOCAL_PREBUILT_MODULE_FILE): build_dir := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)
$(LOCAL_PREBUILT_MODULE_FILE): project_dir := $(abspath $(LOCAL_GRADLE_PROJECT_DIR))
$(LOCAL_PREBUILT_MODULE_FILE): build_file := $(LOCAL_GRADLE_BUILD_FILE)
$(LOCAL_PREBUILT_MODULE_FILE): build_task := $(LOCAL_GRADLE_BUILD_TASK) $(LOCAL_GRADLE_SUBPROJECT):assemble$(task_flavors)
$(LOCAL_PREBUILT_MODULE_FILE):
	gradle --quiet --daemon --parallel --no-search-upward \
		-PbuildDir=$(build_dir) \
		--project-dir $(project_dir) \
		--build-file $(project_dir)/$(build_file) \
		$(build_task)
	@echo -e ${CL_GRN}"Gradle:"${CL_RST}" $@"

include $(BUILD_PREBUILT)
