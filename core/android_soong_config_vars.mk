# Copyright (C) 2020 The Android Open Source Project
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

# This file defines the Soong Config Variable namespace ANDROID, and also any
# variables in that namespace.

# The expectation is that no vendor should be using the ANDROID namespace. This
# check ensures that we don't collide with any existing vendor usage.

ifdef SOONG_CONFIG_ANDROID
$(error The Soong config namespace ANDROID is reserved.)
endif

$(call add_soong_config_namespace,ANDROID)

# Add variables to the namespace below:

$(call add_soong_config_var,ANDROID,BOARD_USES_ODMIMAGE)
$(call soong_config_set_bool,ANDROID,BOARD_USES_RECOVERY_AS_BOOT,$(BOARD_USES_RECOVERY_AS_BOOT))
$(call soong_config_set_bool,ANDROID,BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT,$(BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT))
$(call add_soong_config_var,ANDROID,CHECK_DEV_TYPE_VIOLATIONS)
$(call soong_config_set_bool,ANDROID,HAS_BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS,$(if $(BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS),true,false))
$(call soong_config_set_bool,ANDROID,HAS_BOARD_PRODUCT_SEPOLICY_PREBUILT_DIRS,$(if $(BOARD_PRODUCT_SEPOLICY_PREBUILT_DIRS),true,false))
$(call add_soong_config_var,ANDROID,PLATFORM_SEPOLICY_VERSION)
$(call add_soong_config_var,ANDROID,PLATFORM_SEPOLICY_COMPAT_VERSIONS)
$(call add_soong_config_var,ANDROID,PRODUCT_INSTALL_DEBUG_POLICY_TO_SYSTEM_EXT)
$(call soong_config_set_bool,ANDROID,RELEASE_BOARD_API_LEVEL_FROZEN,$(RELEASE_BOARD_API_LEVEL_FROZEN))
$(call add_soong_config_var,ANDROID,TARGET_DYNAMIC_64_32_DRMSERVER)
$(call add_soong_config_var,ANDROID,TARGET_ENABLE_MEDIADRM_64)
$(call add_soong_config_var,ANDROID,TARGET_DYNAMIC_64_32_MEDIASERVER)
$(call soong_config_set_bool,ANDROID,TARGET_SUPPORTS_32_BIT_APPS,$(if $(filter true,$(TARGET_SUPPORTS_32_BIT_APPS)),true,false))
$(call soong_config_set_bool,ANDROID,TARGET_SUPPORTS_64_BIT_APPS,$(if $(filter true,$(TARGET_SUPPORTS_64_BIT_APPS)),true,false))
$(call add_soong_config_var,ANDROID,BOARD_GENFS_LABELS_VERSION)
$(call soong_config_set_bool,ANDROID,PRODUCT_FSVERITY_GENERATE_METADATA,$(if $(filter true,$(PRODUCT_FSVERITY_GENERATE_METADATA)),true,false))
$(call soong_config_set_bool,ANDROID,TARGET_RESTRICTS_ASHMEM_USAGE,$(TARGET_RESTRICTS_ASHMEM_USAGE))

$(call add_soong_config_var,ANDROID,ADDITIONAL_M4DEFS,$(if $(BOARD_SEPOLICY_M4DEFS),$(addprefix -D,$(BOARD_SEPOLICY_M4DEFS))))
$(call add_soong_config_var,ANDROID,TARGET_ADD_ROOT_EXTRA_VENDOR_SYMLINKS)

# For BUILDING_GSI
$(call soong_config_set_bool,gsi,building_gsi,$(if $(filter true,$(BUILDING_GSI)),true,false))
$(call soong_config_set_bool,gsi,building_lineage_gsi,$(if $(filter true,$(BUILDING_LINEAGE_GSI)),true,false))

# For bootable/recovery
RECOVERY_API_VERSION := 3
RECOVERY_FSTAB_VERSION := 2
$(call soong_config_set, recovery, recovery_api_version, $(RECOVERY_API_VERSION))
$(call soong_config_set, recovery, recovery_fstab_version, $(RECOVERY_FSTAB_VERSION))
$(call soong_config_set_bool, recovery ,target_userimages_use_f2fs ,$(if $(TARGET_USERIMAGES_USE_F2FS),true,false))
$(call soong_config_set_bool, recovery ,has_board_cacheimage_partition_size ,$(if $(BOARD_CACHEIMAGE_PARTITION_SIZE),true,false))
ifdef TARGET_RECOVERY_UI_LIB
  $(call soong_config_set_string_list, recovery, target_recovery_ui_lib, $(TARGET_RECOVERY_UI_LIB))
endif

# For Sanitizers
$(call soong_config_set_bool,ANDROID,ASAN_ENABLED,$(if $(filter address,$(SANITIZE_TARGET)),true,false))
$(call soong_config_set_bool,ANDROID,HWASAN_ENABLED,$(if $(filter hwaddress,$(SANITIZE_TARGET)),true,false))
$(call soong_config_set_bool,ANDROID,SANITIZE_TARGET_SYSTEM_ENABLED,$(if $(filter true,$(SANITIZE_TARGET_SYSTEM)),true,false))
$(call soong_config_set_bool,ANDROID,HAS_SANITIZE_HOST,$(if $(SANITIZE_HOST),true,false))

# For init.environ.rc
$(call soong_config_set_bool,ANDROID,GCOV_COVERAGE,$(NATIVE_COVERAGE))
$(call soong_config_set_bool,ANDROID,CLANG_COVERAGE,$(CLANG_COVERAGE))
$(call soong_config_set,ANDROID,SCUDO_ALLOCATION_RING_BUFFER_SIZE,$(PRODUCT_SCUDO_ALLOCATION_RING_BUFFER_SIZE))

$(call soong_config_set_bool,ANDROID,EMMA_INSTRUMENT,$(if $(filter true,$(EMMA_INSTRUMENT)),true,false))

# PRODUCT_PRECOMPILED_SEPOLICY defaults to true. Explicitly check if it's "false" or not.
$(call soong_config_set_bool,ANDROID,PRODUCT_PRECOMPILED_SEPOLICY,$(if $(filter false,$(PRODUCT_PRECOMPILED_SEPOLICY)),false,true))

# For art modules
$(call soong_config_set_bool,art_module,host_prefer_32_bit,$(if $(filter true,$(HOST_PREFER_32_BIT)),true,false))
ifdef ART_DEBUG_OPT_FLAG
$(call soong_config_set,art_module,art_debug_opt_flag,$(ART_DEBUG_OPT_FLAG))
endif
# The default value of ART_BUILD_HOST_DEBUG is true
$(call soong_config_set_bool,art_module,art_build_host_debug,$(if $(filter false,$(ART_BUILD_HOST_DEBUG)),false,true))
$(call soong_config_set_bool,art_module,art_use_simulator,$(ART_USE_SIMULATOR))

# For ART_BUILD_TARGET in art/build/Android.common_build.mk
# Sets 'art_module_build_target' to true unless both NDEBUG and DEBUG variables are explicitly 'false'.
$(call soong_config_set_bool,art_module,art_build_target, \
  $(if $(filter-out false_marker,$(ART_BUILD_TARGET_NDEBUG)_marker $(ART_BUILD_TARGET_DEBUG)_marker),true,false))
# For ART_BUILD_HOST in art/build/Android.common_build.mk
# Sets 'art_module_build_host' to true unless both NDEBUG and DEBUG variables are explicitly 'false'.
$(call soong_config_set_bool,art_module,art_build_host, \
  $(if $(filter-out false_marker,$(ART_BUILD_HOST_NDEBUG)_marker $(ART_BUILD_HOST_DEBUG)_marker),true,false))

# For chre
$(call soong_config_set_bool,chre,chre_daemon_lpma_enabled,$(if $(filter true,$(CHRE_DAEMON_LPMA_ENABLED)),true,false))
$(call soong_config_set_bool,chre,chre_dedicated_transport_channel_enabled,$(if $(filter true,$(CHRE_DEDICATED_TRANSPORT_CHANNEL_ENABLED)),true,false))
$(call soong_config_set_bool,chre,chre_log_atom_extension_enabled,$(if $(filter true,$(CHRE_LOG_ATOM_EXTENSION_ENABLED)),true,false))
$(call soong_config_set_bool,chre,building_vendor_image,$(if $(filter true,$(BUILDING_VENDOR_IMAGE)),true,false))
$(call soong_config_set_bool,chre,chre_usf_daemon_enabled,$(if $(filter true,$(CHRE_USF_DAEMON_ENABLED)),true,false))

ifdef TARGET_BOARD_AUTO
  $(call add_soong_config_var_value, ANDROID, target_board_auto, $(TARGET_BOARD_AUTO))
endif

# Apex build mode variables
ifdef APEX_BUILD_FOR_PRE_S_DEVICES
$(call add_soong_config_var_value,ANDROID,library_linking_strategy,prefer_static)
else
ifdef KEEP_APEX_INHERIT
$(call add_soong_config_var_value,ANDROID,library_linking_strategy,prefer_static)
endif
endif

# Enable SystemUI optimizations by default unless explicitly set.
SYSTEMUI_OPTIMIZE_JAVA ?= true
$(call add_soong_config_var,ANDROID,SYSTEMUI_OPTIMIZE_JAVA)

# Flag to use baseline profile for SystemUI.
$(call soong_config_set,ANDROID,release_systemui_use_speed_profile,$(RELEASE_SYSTEMUI_USE_SPEED_PROFILE))

# Flag for enabling compose for Launcher.
$(call soong_config_set,ANDROID,release_enable_compose_in_launcher,$(RELEASE_ENABLE_COMPOSE_IN_LAUNCHER))

ifdef PRODUCT_AVF_ENABLED
$(call add_soong_config_var_value,ANDROID,avf_enabled,$(PRODUCT_AVF_ENABLED))
endif

ifdef BOARD_PVMFWIMAGE_PARTITION_SIZE
$(call soong_config_set_int,ANDROID,pvmfw_partition_size,$(BOARD_PVMFWIMAGE_PARTITION_SIZE))
endif

$(call soong_config_set,ANDROID,platform_security_patch_timestamp_string,$(PLATFORM_SECURITY_PATCH_TIMESTAMP))
$(call soong_config_set_int,ANDROID,platform_security_patch_timestamp,$(PLATFORM_SECURITY_PATCH_TIMESTAMP))

# Enable AVF remote attestation if PRODUCT_AVF_REMOTE_ATTESTATION_DISABLED is not set to true explicitly.
ifneq (true,$(PRODUCT_AVF_REMOTE_ATTESTATION_DISABLED))
  $(call add_soong_config_var_value,ANDROID,avf_remote_attestation_enabled,true)
endif

ifdef PRODUCT_AVF_MICRODROID_GUEST_GKI_VERSION
$(call add_soong_config_var_value,ANDROID,avf_microdroid_guest_gki_version,$(PRODUCT_AVF_MICRODROID_GUEST_GKI_VERSION))
endif

ifdef PRODUCT_AVF_MICRODROID_PAGE_REPORTING_ORDER
  ifeq ($(filter $(PRODUCT_AVF_MICRODROID_PAGE_REPORTING_ORDER),0 1 2 3 4 5 6 7 8 9 10),)
    $(error PRODUCT_AVF_MICRODROID_PAGE_REPORTING_ORDER must be between 0 and 10, got $(PRODUCT_AVF_MICRODROID_PAGE_REPORTING_ORDER))
  endif
  $(call add_soong_config_var_value,ANDROID,avf_microdroid_page_reporting_order,$(PRODUCT_AVF_MICRODROID_PAGE_REPORTING_ORDER))
endif

ifdef TARGET_BOOTS_16K
$(call soong_config_set_bool,ANDROID,target_boots_16k,$(filter true,$(TARGET_BOOTS_16K)))
endif

$(call add_soong_config_var_value,ANDROID,release_avf_allow_preinstalled_apps,$(RELEASE_AVF_ALLOW_PREINSTALLED_APPS))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_device_assignment,$(RELEASE_AVF_ENABLE_DEVICE_ASSIGNMENT))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_dice_changes,$(RELEASE_AVF_ENABLE_DICE_CHANGES))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_early_vm,$(RELEASE_AVF_ENABLE_EARLY_VM))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_llpvm_changes,$(RELEASE_AVF_ENABLE_LLPVM_CHANGES))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_multi_tenant_microdroid_vm,$(RELEASE_AVF_ENABLE_MULTI_TENANT_MICRODROID_VM))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_network,$(RELEASE_AVF_ENABLE_NETWORK))
# TODO(b/341292601): This flag is needed until the V release. We with clean it up after V together
# with most of the release_avf_ flags here.
$(call add_soong_config_var_value,ANDROID,release_avf_enable_vendor_modules,$(RELEASE_AVF_ENABLE_VENDOR_MODULES))
$(call add_soong_config_var_value,ANDROID,release_avf_enable_virt_cpufreq,$(RELEASE_AVF_ENABLE_VIRT_CPUFREQ))
$(call add_soong_config_var_value,ANDROID,release_avf_microdroid_kernel_version,$(RELEASE_AVF_MICRODROID_KERNEL_VERSION))
$(call add_soong_config_var_value,ANDROID,release_avf_support_custom_vm_with_paravirtualized_devices,$(RELEASE_AVF_SUPPORT_CUSTOM_VM_WITH_PARAVIRTUALIZED_DEVICES))

$(call add_soong_config_var_value,ANDROID,release_binder_death_recipient_weak_from_jni,$(RELEASE_BINDER_DEATH_RECIPIENT_WEAK_FROM_JNI))

$(call add_soong_config_var_value,ANDROID,release_libpower_no_lock_binder_txn,$(RELEASE_LIBPOWER_NO_LOCK_BINDER_TXN))

$(call add_soong_config_var_value,ANDROID,release_selinux_data_data_ignore,$(RELEASE_SELINUX_DATA_DATA_IGNORE))
ifneq (,$(filter eng userdebug,$(TARGET_BUILD_VARIANT)))
    # write appcompat system properties on userdebug and eng builds
    $(call add_soong_config_var_value,ANDROID,release_write_appcompat_override_system_properties,true)
endif

# Enable system_server optimizations by default unless explicitly set or if
# there may be dependent runtime jars.
# TODO(b/240588226): Remove the off-by-default exceptions after handling
# system_server jars automatically w/ R8.
ifeq (true,$(PRODUCT_BROKEN_SUBOPTIMAL_ORDER_OF_SYSTEM_SERVER_JARS))
  # If system_server jar ordering is broken, don't assume services.jar can be
  # safely optimized in isolation, as there may be dependent jars.
  SYSTEM_OPTIMIZE_JAVA ?= false
else ifneq (platform:services,$(lastword $(PRODUCT_SYSTEM_SERVER_JARS)))
  # If services is not the final jar in the dependency ordering, don't assume
  # it can be safely optimized in isolation, as there may be dependent jars.
  # TODO(b/212737576): Remove this exception after integrating use of `$(system_server_trace_refs)`.
  SYSTEM_OPTIMIZE_JAVA ?= false
else
  SYSTEM_OPTIMIZE_JAVA ?= true
endif

ifeq (true,$(FULL_SYSTEM_OPTIMIZE_JAVA))
  SYSTEM_OPTIMIZE_JAVA := true
endif

$(call add_soong_config_var,ANDROID,SYSTEM_OPTIMIZE_JAVA)
$(call add_soong_config_var,ANDROID,FULL_SYSTEM_OPTIMIZE_JAVA)

ifeq (true, $(SYSTEM_OPTIMIZE_JAVA))
  # Create a list of (non-prefixed) system server jars that follow `services` in
  # the classpath. This can be used when optimizing `services` to trace any
  # downstream references that need keeping.
  # Example: "foo:service1 platform:services bar:services2" -> "services2"
  system_server_jars_dependent_on_services := $(shell \
      echo "$(PRODUCT_SYSTEM_SERVER_JARS)" | \
      awk '{found=0; for(i=1;i<=NF;i++){if($$i=="platform:services"){found=1; continue} if(found){split($$i,a,":"); print a[2]}}}' | \
      xargs)
  ifneq ($(strip $(system_server_jars_dependent_on_services)),)
    $(call soong_config_set_string_list,ANDROID,system_server_trace_refs,$(system_server_jars_dependent_on_services))
  endif
endif

# TODO(b/319697968): Remove this build flag support when metalava fully supports flagged api
$(call soong_config_set,ANDROID,release_hidden_api_exportable_stubs,$(RELEASE_HIDDEN_API_EXPORTABLE_STUBS))

# Check for SupplementalApi module.
ifeq ($(wildcard packages/modules/SupplementalApi),)
$(call add_soong_config_var_value,ANDROID,include_nonpublic_framework_api,false)
else
$(call add_soong_config_var_value,ANDROID,include_nonpublic_framework_api,true)
endif

# Add nfc build flag to soong
ifneq ($(RELEASE_PACKAGE_NFC_STACK),NfcNci)
  $(call soong_config_set,bootclasspath,nfc_apex_bootclasspath_fragment,true)
endif

# Add uwb build flag to soong
$(call soong_config_set,bootclasspath,release_ranging_stack,$(RELEASE_RANGING_STACK))



# Add ondeviceintelligence module build flag to soong
ifeq (true,$(RELEASE_ONDEVICE_INTELLIGENCE_MODULE))
    $(call soong_config_set,ANDROID,release_ondevice_intelligence_module,true)
    # Required as platform_bootclasspath is using this namespace
    $(call soong_config_set,bootclasspath,release_ondevice_intelligence_module,true)

else
    $(call soong_config_set,ANDROID,release_ondevice_intelligence_platform,true)
    $(call soong_config_set,bootclasspath,release_ondevice_intelligence_platform,true)

endif

# Add RELEASE_DEPRECATE_RUNTIME_APEX to soong
$(call soong_config_set_bool,ANDROID,release_deprecate_runtime_apex,$(RELEASE_DEPRECATE_RUNTIME_APEX))

# Add uprobestats build flags to soong
$(call soong_config_set,ANDROID,release_uprobestats_bridge_service,$(RELEASE_UPROBESTATS_BRIDGE_SERVICE))
$(call soong_config_set,bootclasspath,release_uprobestats_bridge_service,$(RELEASE_UPROBESTATS_BRIDGE_SERVICE))
# Add uprobestats file move flags to soong, for both platform and module
ifeq (true,$(RELEASE_UPROBESTATS_FILE_MOVE))
  $(call soong_config_set,ANDROID,uprobestats_files_in_module,true)
  $(call soong_config_set,ANDROID,uprobestats_files_in_platform,false)
else
  $(call soong_config_set,ANDROID,uprobestats_files_in_module,false)
  $(call soong_config_set,ANDROID,uprobestats_files_in_platform,true)
endif

# Enable Profiling module. Also used by platform_bootclasspath.
$(call soong_config_set,ANDROID,release_package_profiling_module,$(RELEASE_PACKAGE_PROFILING_MODULE))
$(call soong_config_set,bootclasspath,release_package_profiling_module,$(RELEASE_PACKAGE_PROFILING_MODULE))

# Enable anomaly detector inside the Profiling module. Also used by platform_bootclasspath.
$(call soong_config_set,ANDROID,release_anomaly_detector,$(RELEASE_ANOMALY_DETECTOR))
$(call soong_config_set,bootclasspath,release_anomaly_detector,$(RELEASE_ANOMALY_DETECTOR))

# Move Telecom APIs into telephonycore; used by both platform and module
$(call soong_config_set,ANDROID,release_telecom_mainline_module,$(RELEASE_TELECOM_MAINLINE_MODULE))

# Add telephony build flag to soong
$(call soong_config_set,ANDROID,release_telephony_module,$(RELEASE_TELEPHONY_MODULE))
$(call soong_config_set,bootclasspath,release_telephony_module,$(RELEASE_TELEPHONY_MODULE))

# Add npumanager build flag to soong
$(call soong_config_set,ANDROID,release_npumanager_module,$(RELEASE_NPUMANAGER_MODULE))
$(call soong_config_set,bootclasspath,release_npumanager_module,$(RELEASE_NPUMANAGER_MODULE))

# Add webapp build flag to soong
$(call soong_config_set,ANDROID,release_webapp_module,$(RELEASE_WEBAPP_MODULE))
$(call soong_config_set,bootclasspath,release_webapp_module,$(RELEASE_WEBAPP_MODULE))

# Add bettertogether build flag to soong
$(call soong_config_set,ANDROID,release_bettertogether_module,$(RELEASE_BETTERTOGETHER_MODULE))
$(call soong_config_set,bootclasspath,release_bettertogether_module,$(RELEASE_BETTERTOGETHER_MODULE))

# Add perf-setup build flag to soong
# Note: BOARD_PERFSETUP_SCRIPT location must be under platform_testing/scripts/perf-setup/.
ifdef BOARD_PERFSETUP_SCRIPT
  $(call soong_config_set,perf,board_perfsetup_script,$(notdir $(BOARD_PERFSETUP_SCRIPT)))
endif

# Add target_use_pan_display flag for hardware/libhardware:gralloc.default
$(call soong_config_set_bool,gralloc,target_use_pan_display,$(if $(filter true,$(TARGET_USE_PAN_DISPLAY)),true,false))

# Add use_camera_v4l2_hal flag for hardware/libhardware/modules/camera/3_4:camera.v4l2
$(call soong_config_set_bool,camera,use_camera_v4l2_hal,$(if $(filter true,$(USE_CAMERA_V4L2_HAL)),true,false))

# Add audioserver_multilib flag for hardware/interfaces/soundtrigger/2.0/default:android.hardware.soundtrigger@2.0-impl
ifneq ($(strip $(AUDIOSERVER_MULTILIB)),)
  $(call soong_config_set,soundtrigger,audioserver_multilib,$(AUDIOSERVER_MULTILIB))
endif

# Add sim_count, disable_rild_oem_hook, and use_aosp_rild flag for ril related modules
$(call soong_config_set,ril,sim_count,$(SIM_COUNT))
ifneq ($(DISABLE_RILD_OEM_HOOK), false)
  $(call soong_config_set_bool,ril,disable_rild_oem_hook,true)
endif
ifneq ($(ENABLE_VENDOR_RIL_SERVICE), true)
  $(call soong_config_set_bool,ril,use_aosp_rild,true)
endif

# Export target_board_platform to soong for hardware/google/graphics/common/libmemtrack:memtrack.$(TARGET_BOARD_PLATFORM)
$(call soong_config_set,ANDROID,target_board_platform,$(TARGET_BOARD_PLATFORM))

# Export board_uses_scaler_m2m1shot and board_uses_align_restriction to soong for hardware/google/graphics/common/libscaler:libexynosscaler
$(call soong_config_set_bool,google_graphics,board_uses_scaler_m2m1shot,$(if $(filter true,$(BOARD_USES_SCALER_M2M1SHOT)),true,false))
$(call soong_config_set_bool,google_graphics,board_uses_align_restriction,$(if $(filter true,$(BOARD_USES_ALIGN_RESTRICTION)),true,false))

# Export related variables to soong for hardware/google/graphics/common/libacryl:libacryl
ifdef BOARD_LIBACRYL_DEFAULT_COMPOSITOR
  $(call soong_config_set,acryl,libacryl_default_compositor,$(BOARD_LIBACRYL_DEFAULT_COMPOSITOR))
endif
ifdef BOARD_LIBACRYL_DEFAULT_SCALER
  $(call soong_config_set,acryl,libacryl_default_scaler,$(BOARD_LIBACRYL_DEFAULT_SCALER))
endif
ifdef BOARD_LIBACRYL_DEFAULT_BLTER
  $(call soong_config_set,acryl,libacryl_default_blter,$(BOARD_LIBACRYL_DEFAULT_BLTER))
endif
ifdef BOARD_LIBACRYL_G2D_HDR_PLUGIN
  #BOARD_LIBACRYL_G2D_HDR_PLUGIN is set in each board config
  $(call soong_config_set_bool,acryl,libacryl_use_g2d_hdr_plugin,true)
endif

# Export related variables to soong for hardware/google/graphics/common/BoardConfigCFlags.mk
$(call soong_config_set_bool,google_graphics,hwc_no_support_skip_validate,$(if $(filter true,$(HWC_NO_SUPPORT_SKIP_VALIDATE)),true,false))
$(call soong_config_set_bool,google_graphics,hwc_support_color_transform,$(if $(filter true,$(HWC_SUPPORT_COLOR_TRANSFORM)),true,false))
$(call soong_config_set_bool,google_graphics,hwc_support_render_intent,$(if $(filter true,$(HWC_SUPPORT_RENDER_INTENT)),true,false))
$(call soong_config_set_bool,google_graphics,board_uses_virtual_display,$(if $(filter true,$(BOARD_USES_VIRTUAL_DISPLAY)),true,false))
$(call soong_config_set_bool,google_graphics,board_uses_dt,$(if $(filter true,$(BOARD_USES_DT)),true,false))
$(call soong_config_set_bool,google_graphics,board_uses_decon_64bit_address,$(if $(filter true,$(BOARD_USES_DECON_64BIT_ADDRESS)),true,false))
$(call soong_config_set_bool,google_graphics,board_uses_hdrui_gles_conversion,$(if $(filter true,$(BOARD_USES_HDRUI_GLES_CONVERSION)),true,false))
$(call soong_config_set_bool,google_graphics,uses_idisplay_intf_sec,$(if $(filter true,$(USES_IDISPLAY_INTF_SEC)),true,false))

# Variables for fs_config
$(call soong_config_set_bool,fs_config,vendor,$(if $(BOARD_USES_VENDORIMAGE)$(BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE),true,false))
$(call soong_config_set_bool,fs_config,oem,$(if $(BOARD_USES_OEMIMAGE)$(BOARD_OEMIMAGE_FILE_SYSTEM_TYPE),true,false))
$(call soong_config_set_bool,fs_config,odm,$(if $(BOARD_USES_ODMIMAGE)$(BOARD_ODMIMAGE_FILE_SYSTEM_TYPE),true,false))
$(call soong_config_set_bool,fs_config,vendor_dlkm,$(if $(BOARD_USES_VENDOR_DLKMIMAGE)$(BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE),true,false))
$(call soong_config_set_bool,fs_config,odm_dlkm,$(if $(BOARD_USES_ODM_DLKMIMAGE)$(BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE),true,false))
$(call soong_config_set_bool,fs_config,system_dlkm,$(if $(BOARD_USES_SYSTEM_DLKMIMAGE)$(BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE),true,false))

# Variables for telephony
$(call soong_config_set_bool,telephony,sec_cp_secure_boot,$(if $(filter true,$(SEC_CP_SECURE_BOOT)),true,false))
$(call soong_config_set_bool,telephony,cbd_protocol_sit,$(if $(filter true,$(CBD_PROTOCOL_SIT)),true,false))
$(call soong_config_set_bool,telephony,use_radioexternal_hal_aidl,$(if $(filter true,$(USE_RADIOEXTERNAL_HAL_AIDL)),true,false))

# Variables for hwcomposer.$(TARGET_BOARD_PLATFORM)
$(call soong_config_set_bool,google_graphics,board_uses_hwc_services,$(if $(filter true,$(BOARD_USES_HWC_SERVICES)),true,false))

# Variables for controlling android.hardware.composer.hwc3-service.pixel
$(call soong_config_set,google_graphics,board_hwc_version,$(BOARD_HWC_VERSION))

# Flag ExcludeExtractApk is to support "extract_apk" property for the following conditions.
ifneq ($(WITH_DEXPREOPT),true)
  $(call soong_config_set_bool,PrebuiltGmsCore,ExcludeExtractApk,true)
endif
ifeq ($(DONT_DEXPREOPT_PREBUILTS),true)
  $(call soong_config_set_bool,PrebuiltGmsCore,ExcludeExtractApk,true)
endif
ifeq ($(WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY),true)
  $(call soong_config_set_bool,PrebuiltGmsCore,ExcludeExtractApk,true)
endif

# Variables for extra branches
# TODO(b/383238397): Use bootstrap_go_package to enable extra flags.
-include vendor/google/build/extra_soong_config_vars.mk

# Variable for CI test packages
ifneq ($(filter arm x86 true,$(TARGET_ARCH) $(TARGET_2ND_ARCH) $(TARGET_ENABLE_MEDIADRM_64)),)
  $(call soong_config_set_bool,ci_tests,uses_widevine_tests, true)
endif

# Flags used in GTVS prebuilt apps
$(call soong_config_set_bool,GTVS,GTVS_COMPRESSED_PREBUILTS,$(if $(findstring $(GTVS_COMPRESSED_PREBUILTS),true yes),true,false))
$(call soong_config_set_bool,GTVS,GTVS_GMSCORE_BETA,$(if $(findstring $(GTVS_GMSCORE_BETA),true yes),true,false))
$(call soong_config_set_bool,GTVS,GTVS_SETUPWRAITH_BETA,$(if $(findstring $(GTVS_SETUPWRAITH_BETA),true yes),true,false))
$(call soong_config_set_bool,GTVS,PRODUCT_USE_PREBUILT_GTVS,$(if $(findstring $(PRODUCT_USE_PREBUILT_GTVS),true yes),true,false))

# Flags used in GTVS_GTV prebuilt apps
$(call soong_config_set_bool,GTVS_GTV,PRODUCT_USE_PREBUILT_GTVS_GTV,$(if $(findstring $(PRODUCT_USE_PREBUILT_GTVS_GTV),true yes),true,false))

# Check modules to be built in "otatools-package".
ifneq ($(wildcard vendor/google/tools/build_mixed_kernels_ramdisk),)
  $(call soong_config_set_bool,otatools,use_build_mixed_kernels_ramdisk,true)
endif
ifneq ($(wildcard bootable/deprecated-ota/applypatch),)
  $(call soong_config_set_bool,otatools,use_bootable_deprecated_ota_applypatch,true)
endif

# Flags used in building continuous_native_tests
ifeq ($(BOARD_IS_AUTOMOTIVE), true)
  $(call soong_config_set_bool,ANDROID,board_is_automotive,true)
endif
ifneq ($(filter vendor/google/darwinn,$(PRODUCT_SOONG_NAMESPACES)),)
  $(call soong_config_set_bool,ci_tests,uses_darwinn_tests,true)
endif

# Flags used in building continuous_instrumentation_tests
ifneq ($(filter StorageManager, $(PRODUCT_PACKAGES)),)
  $(call soong_config_set_bool,ci_tests,uses_storage_manager_tests,true)
endif

ifneq ($(BUILD_OS),darwin)
  ifneq ($(TARGET_SKIP_OTATOOLS_PACKAGE),true)
    $(call soong_config_set_bool,otatools,use_otatools_package,true)
  endif
endif

# Flags for Android Multiuser configuration
$(call soong_config_set_bool,ANDROID_MULTIUSER,PRODUCT_USE_HSUM,$(if $(filter true,$(PRODUCT_USE_HSUM)),true,false))

# Variables for qcom bluetooth modules.
$(call soong_config_set,qcom_bluetooth,TARGET_BLUETOOTH_UART_DEVICE,$(TARGET_BLUETOOTH_UART_DEVICE))
$(call soong_config_set_bool,qcom_bluetooth,BOARD_HAVE_QCOM_FM,$(if $(filter true,$(BOARD_HAVE_QCOM_FM)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,BOARD_HAVE_QTI_BT_LAZY_SERVICE,$(if $(filter true,$(BOARD_HAVE_QTI_BT_LAZY_SERVICE)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,QCOM_BLUETOOTH_USING_DIAG,$(if $(filter true,$(QCOM_BLUETOOTH_USING_DIAG)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_BLUETOOTH_HCI_V1_1,$(if $(filter true,$(TARGET_BLUETOOTH_HCI_V1_1)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_BLUETOOTH_SUPPORT_QMI_ADDRESS,$(if $(filter true,$(TARGET_BLUETOOTH_SUPPORT_QMI_ADDRESS)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_DROP_BYTES_BEFORE_SSR_DUMP,$(if $(filter true,$(TARGET_DROP_BYTES_BEFORE_SSR_DUMP)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_CHANNEL_AVOIDANCE,$(if $(filter true,$(TARGET_USE_QTI_BT_CHANNEL_AVOIDANCE)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_EXT,$(if $(filter true,$(TARGET_USE_QTI_BT_EXT)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_CONFIGSTORE,$(if $(filter true,$(TARGET_USE_QTI_BT_CONFIGSTORE)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_IBS,$(if $(filter true,$(TARGET_USE_QTI_BT_IBS)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_OBS,$(if $(filter true,$(TARGET_USE_QTI_BT_OBS)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_SAR,$(if $(filter true,$(TARGET_USE_QTI_BT_SAR)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_BT_SAR_V1_1,$(if $(filter true,$(TARGET_USE_QTI_BT_SAR_V1_1)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,TARGET_USE_QTI_VND_FWK_DETECT,$(if $(filter true,$(TARGET_USE_QTI_VND_FWK_DETECT)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,UART_BAUDRATE_3_0_MBPS,$(if $(filter true,$(UART_BAUDRATE_3_0_MBPS)),true,false))
$(call soong_config_set_bool,qcom_bluetooth,UART_USE_TERMIOS_AFC,$(if $(filter true,$(UART_USE_TERMIOS_AFC)),true,false))

# Flags for Fingerprint HAL
$(call soong_config_set,fp_hal_feature,FPC_CONFIG_KEYMASTER_APP_PATH,$(FPC_CONFIG_KEYMASTER_APP_PATH))
$(call soong_config_set,fp_hal_feature,FPC_CONFIG_KEYMASTER_NAME,$(FPC_CONFIG_KEYMASTER_NAME))
$(call soong_config_set,fp_hal_feature,FPC_CONFIG_SENSE_TOUCH_CALIBRATION_PATH,$(FPC_CONFIG_SENSE_TOUCH_CALIBRATION_PATH))
$(call soong_config_set,fp_hal_feature,FPC_MODULE_TYPE,$(FPC_MODULE_TYPE))
$(call soong_config_set,fp_hal_feature,FPC_PLATFORM_TARGET,$(FPC_PLATFORM_TARGET))
$(call soong_config_set,fp_hal_feature,FPC_TEE_RUNTIME,$(FPC_TEE_RUNTIME))
ifneq ($(FPC_CONFIG_RETRY_MATCH_TIMEOUT),)
  $(call soong_config_set,fp_hal_feature,FPC_CONFIG_RETRY_MATCH_TIMEOUT,$(FPC_CONFIG_RETRY_MATCH_TIMEOUT))
endif
ifneq ($(GOOGLE_CONFIG_DP_COUNT),)
  $(call soong_config_set,fp_hal_feature,GOOGLE_CONFIG_DP_COUNT,$(GOOGLE_CONFIG_DP_COUNT))
endif
ifneq ($(GOOGLE_CONFIG_POWER_NODE),)
  $(call soong_config_set,fp_hal_feature,GOOGLE_CONFIG_POWER_NODE,$(GOOGLE_CONFIG_POWER_NODE))
endif

$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_DEBUG,$(if $(filter 1,$(FPC_CONFIG_DEBUG)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_ENGINEERING,$(if $(FPC_CONFIG_ENGINEERING),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_ENROL_TIMEOUT,$(if $(filter 1,$(FPC_CONFIG_ENROL_TIMEOUT)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_FIDO_AUTH,$(if $(FPC_CONFIG_FIDO_AUTH),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_FIDO_AUTH_VER_GMRZ,$(if $(filter 1,$(FPC_CONFIG_FIDO_AUTH_VER_GMRZ)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_HW_AUTH,$(if $(filter 1,$(FPC_CONFIG_HW_AUTH)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_GOOGLE_CUSTOMIZE,$(if $(filter 1,$(FPC_CONFIG_GOOGLE_CUSTOMIZE)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_GOOGLE_RELEASE,$(if $(filter 1,$(FPC_CONFIG_GOOGLE_RELEASE)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_NAVIGATION,$(if $(FPC_CONFIG_NAVIGATION),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_NO_ALGO,$(if $(FPC_CONFIG_NO_ALGO),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_NO_SENSOR,$(if $(FPC_CONFIG_NO_SENSOR),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_NORMAL_SENSOR_RESET,$(if $(FPC_CONFIG_NORMAL_SENSOR_RESET),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_NORMAL_SPI_RESET,$(if $(FPC_CONFIG_NORMAL_SPI_RESET),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_SENSORTEST,$(if $(FPC_CONFIG_SENSORTEST),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_SWIPE_ENROL,$(if $(filter 1,$(FPC_CONFIG_SWIPE_ENROL)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_TA_FS,$(if $(FPC_CONFIG_TA_FS),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_TRUSTY_CLEAN_TA,$(if $(filter 1,$(FPC_CONFIG_TRUSTY_CLEAN_TA)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_TRUSTY_EMULATOR,$(if $(filter 1,$(FPC_CONFIG_TRUSTY_EMULATOR)),true,false))
$(call soong_config_set_bool,fp_hal_feature,FPC_CONFIG_TRUSTY_SC,$(if $(filter 1,$(FPC_CONFIG_TRUSTY_SC)),true,false))
$(call soong_config_set_bool,fp_hal_feature,GOOGLE_CONFIG_PERFORMANCE,$(if $(filter 1,$(GOOGLE_CONFIG_PERFORMANCE)),true,false))
$(call soong_config_set_bool,fp_hal_feature,GOOGLE_CONFIG_TOUCH_TO_UNLOCK_ANYTIME,$(if $(filter 1,$(GOOGLE_CONFIG_TOUCH_TO_UNLOCK_ANYTIME)),true,false))

# Flag for building static_apexer_tools
$(call soong_config_set_bool,ANDROID,BUILD_HOST_static,$(if $(filter true 1,$(BUILD_HOST_static)),true,false))

# Flag for using SetupWizardCar certificate
$(call soong_config_set_bool,AUTO,USE_AUTOMTIVE_SETUPWIZARD_TEST_CERTIFICATE,$(if $(filter true,$(USE_AUTOMTIVE_SETUPWIZARD_TEST_CERTIFICATE)),true,false))

# This flag is used to control to use tools/tradefederation/core or
# tools/tradefederation/prebuilts for tradefederation.
ifeq (,$(wildcard tools/tradefederation/core))
$(call soong_config_set_bool,tradefed,use_prebuilt,true)
else
$(call soong_config_set_bool,tradefed,use_prebuilt,false)
endif

$(call soong_config_set,berberis,target_native_bridge_abi,$(TARGET_NATIVE_BRIDGE_ABI))

# Flags for SDK packages
$(call soong_config_set,sdk,PLATFORM_VERSION,$(PLATFORM_VERSION))
$(call soong_config_set,sdk,PLATFORM_SDK_VERSION,$(PLATFORM_SDK_VERSION_FULL))
$(call soong_config_set,sdk,PLATFORM_SDK_EXTENSION_VERSION,$(PLATFORM_SDK_EXTENSION_VERSION))
$(call soong_config_set,sdk,PLATFORM_IS_BASE_SDK,$(if $(filter $(PLATFORM_SDK_EXTENSION_VERSION),$(PLATFORM_BASE_SDK_EXTENSION_VERSION)),true,false))
$(call soong_config_set,sdk,PLATFORM_VERSION_CODENAME,$(subst REL,,$(PLATFORM_VERSION_CODENAME)))
$(call soong_config_set,sdk,PLATFORM_PREVIEW_SDK_VERSION,$(PLATFORM_PREVIEW_SDK_VERSION))
$(call soong_config_set,sdk,BETA_SDK_VERSION,$(shell if [[ "$(PLATFORM_PREVIEW_SDK_VERSION)" =~ ^[0-9]{4}$$ ]]; then echo "$(PLATFORM_PREVIEW_SDK_VERSION)" | cut -c4 ; fi))

# Flags for SDK plarforms package folder, move from build/core/Makefile
# The name of the subdir within the platforms dir of the sdk.
#   if canary build          : android-canary-$PREVIEW_SDK_INT         (android-canary-20250617)
#   if beta build            : android-$UPCOMING_SDK_INT_FULL-ext$BETA (android-36.1-beta2)
#   if REL                   : android-$SDK_INT_FULL                   (android-36.1)
#   if REL with newer SDK ext: android-$SDK_INT_FULL-ext$SDK_EXT       (android-36.1-ext22)
#   else (internal DEV)      : android-$CODENAME                       (android-CinnamonBun)
ifeq ($(PLATFORM_VERSION_CODENAME),CANARY)
sdk_platform_dir_name := android-canary-$(PLATFORM_PREVIEW_SDK_VERSION)
else ifeq (,$(filter $(PLATFORM_PREVIEW_SDK_VERSION),0 1))
major := $(shell echo "$(PLATFORM_PREVIEW_SDK_VERSION)" | cut -c 1-2)
minor := $(shell echo "$(PLATFORM_PREVIEW_SDK_VERSION)" | cut -c 3)
beta := $(shell echo "$(PLATFORM_PREVIEW_SDK_VERSION)" | cut -c 4)
sdk_platform_dir_name := android-$(major).$(minor)-beta$(beta)
else ifeq ($(PLATFORM_VERSION_CODENAME),REL)
  ifeq ($(PLATFORM_SDK_EXTENSION_VERSION),$(PLATFORM_BASE_SDK_EXTENSION_VERSION))
    sdk_platform_dir_name := android-$(PLATFORM_SDK_VERSION_FULL)
  else
    sdk_platform_dir_name := android-$(PLATFORM_SDK_VERSION_FULL)-ext$(PLATFORM_SDK_EXTENSION_VERSION)
  endif
else
sdk_platform_dir_name := android-$(PLATFORM_VERSION_CODENAME)
endif
$(call soong_config_set,sdk,sdk_platform_dir_name,$(sdk_platform_dir_name))
