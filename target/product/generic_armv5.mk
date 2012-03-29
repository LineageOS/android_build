#
# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

<<<<<<< HEAD:target/product/generic_armv5.mk
# This is a generic product that isn't specialized for a specific device.
# It includes the base Android platform.
=======
gpl_source_tgz := $(call intermediates-dir-for,PACKAGING,gpl_source,HOST,COMMON)/gpl_source.tgz

$(gpl_source_tgz): PRIVATE_PATHS := $(sort $(patsubst %/, %, $(dir $(ALL_GPL_MODULE_LICENSE_FILES))))
$(gpl_source_tgz) : $(ALL_GPL_MODULE_LICENSE_FILES)
	@echo -e ${CL_GRN}"Package gpl sources:"${CL_RST}" $@"
	@rm -rf $(dir $@) && mkdir -p $(dir $@)
	$(hide) tar cfz $@ --exclude ".git*" $(PRIVATE_PATHS)

>>>>>>> cd5ea04... build-with-colors: moar colors:core/tasks/collect_gpl_sources.mk

$(call inherit-product, $(SRC_TARGET_DIR)/product/generic.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core.mk)

# Overrides
PRODUCT_BRAND := generic_armv5
PRODUCT_DEVICE := generic_armv5
PRODUCT_NAME := generic_armv5
