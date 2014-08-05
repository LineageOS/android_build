#
# Copyright (C) 2014 Cyanogen, Inc.
#

ifeq ($(strip $(LOCAL_MAVEN_GROUP)),)
  $(error LOCAL_MAVEN_GROUP not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_ARTIFACT)),)
  $(error LOCAL_MAVEN_ARTIFACT not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_VERSION)),)
  $(error LOCAL_MAVEN_VERSION not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_PACKAGING)),)
  LOCAL_MAVEN_PACKAGING := jar
endif
ifeq ($(strip $(LOCAL_MAVEN_REPO)),)
  LOCAL_MAVEN_REPO := https://maven.cyngn.com/artifactory/repo
endif

artifact_filename := $(LOCAL_MAVEN_GROUP).$(LOCAL_MAVEN_ARTIFACT)-$(LOCAL_MAVEN_VERSION).$(LOCAL_MAVEN_PACKAGING)

LOCAL_PREBUILT_MODULE_FILE := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),,COMMON)/$(artifact_filename)

$(LOCAL_PREBUILT_MODULE_FILE): specifier := $(LOCAL_MAVEN_GROUP):$(LOCAL_MAVEN_ARTIFACT):$(LOCAL_MAVEN_VERSION):$(LOCAL_MAVEN_PACKAGING)
$(LOCAL_PREBUILT_MODULE_FILE): repo := $(LOCAL_MAVEN_REPO)
$(LOCAL_PREBUILT_MODULE_FILE):
	@mvn -q dependency:get dependency:copy \
		-DremoteRepositories=central::::$(repo) \
		-Dartifact=$(specifier) \
		-DoutputDirectory=$(dir $@) \
		-Dmdep.prependGroupId=true \
		-Dmdep.overWriteSnapshots=true \
		-Dmdep.overWriteReleases=true
	@echo -e ${CL_GRN}"Download:"${CL_RST}" $@"

include $(BUILD_PREBUILT)

# the "fetchprebuilts" target will go through and pre-download all of the maven dependencies in the tree
fetchprebuilts: $(LOCAL_PREBUILT_MODULE_FILE)