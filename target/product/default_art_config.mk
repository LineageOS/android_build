#
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
#

# This file contains product config for the ART module that is common for
# platform and unbundled builds.

ifeq ($(ART_APEX_JARS),)
  $(error ART_APEX_JARS is empty; cannot initialize PRODUCT_BOOT_JARS variable)
endif

# Order of the jars on BOOTCLASSPATH follows:
# 1. ART APEX jars
# 2. System jars
# 3. System_ext jars
# 4. Non-updatable APEX jars
# 5. Updatable APEX jars
#
# ART APEX jars (1) are defined in ART_APEX_JARS. System and system_ext boot jars are defined below
# in PRODUCT_BOOT_JARS. All other non-art APEX boot jars are part of the PRODUCT_APEX_BOOT_JARS.
#
# The actual runtime ordering matching above is determined by derive_classpath service at runtime.
# See packages/modules/SdkExtensions/README.md for more details.

# The order of PRODUCT_BOOT_JARS matters for runtime class lookup performance.
PRODUCT_BOOT_JARS := \
    $(ART_APEX_JARS)

# List of jars to be included in the ART boot image for testing.
# DO NOT reorder this list. The order must match the one described above.
# Note: We use the host variant of "core-icu4j" and "conscrypt" for testing.
PRODUCT_TEST_ONLY_ART_BOOT_IMAGE_JARS := \
    $(ART_APEX_JARS) \
    platform:core-icu4j-host \
    platform:conscrypt-host \

# /system and /system_ext boot jars.
PRODUCT_BOOT_JARS += \
    framework-minus-apex \
    framework-graphics \
    framework-location \
    ext \
    telephony-common \
    voip-common \
    ims-common

# APEX boot jars. Keep the list sorted by module names and then library names.
# Note: If the existing apex introduces the new jar, also add it to
# PRODUCT_APEX_BOOT_JARS_FOR_SOURCE_BUILD_ONLY below.
# Note: core-icu4j is moved back to PRODUCT_BOOT_JARS in product_config.mk at a later stage.
# Note: For modules available in Q, DO NOT add new entries here.
PRODUCT_APEX_BOOT_JARS := \
    com.android.adservices:framework-adservices \
    com.android.adservices:framework-sdksandbox \
    com.android.appsearch:framework-appsearch \
    com.android.bt:framework-bluetooth \
    com.android.configinfrastructure:framework-configinfrastructure \
    com.android.conscrypt:conscrypt \
    com.android.crashrecovery:framework-crashrecovery \
    com.android.devicelock:framework-devicelock \
    com.android.healthfitness:framework-healthfitness \
    com.android.i18n:core-icu4j \
    com.android.ipsec:android.net.ipsec.ike \
    com.android.media:updatable-media \
    com.android.mediaprovider:framework-mediaprovider \
    com.android.mediaprovider:framework-pdf \
    com.android.mediaprovider:framework-pdf-v \
    com.android.mediaprovider:framework-photopicker \
    com.android.ondevicepersonalization:framework-ondevicepersonalization \
    com.android.os.statsd:framework-statsd \
    com.android.permission:framework-permission \
    com.android.permission:framework-permission-s \
    com.android.scheduling:framework-scheduling \
    com.android.sdkext:framework-sdkextensions \
    com.android.tethering:framework-connectivity \
    com.android.tethering:framework-connectivity-t \
    com.android.tethering:framework-connectivity-b \
    com.android.tethering:framework-tethering \
    com.android.uwb:framework-uwb \
    com.android.virt:framework-virtualization \
    com.android.wifi:framework-wifi \

# When we release ondeviceintelligence in NeuralNetworks module
ifeq ($(RELEASE_ONDEVICE_INTELLIGENCE_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
    com.android.neuralnetworks:framework-ondeviceintelligence \

else
    PRODUCT_BOOT_JARS += \
        framework-ondeviceintelligence-platform \

endif

# When we release NSC in Conscrypt.
ifeq ($(RELEASE_CONSCRYPT_NSC),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.conscrypt:framework-conscrypt-nsc \

else
    PRODUCT_BOOT_JARS += \
        framework-network-security-config \

endif

# Check if the build supports NFC apex or not
ifeq ($(RELEASE_PACKAGE_NFC_STACK),NfcNci)
    PRODUCT_BOOT_JARS += \
        framework-nfc
else
    PRODUCT_APEX_BOOT_JARS += \
        com.android.nfcservices:framework-nfc
    $(call soong_config_set,bootclasspath,nfc_apex_bootclasspath_fragment,true)
endif

# Check if build supports Profiling module.
ifeq ($(RELEASE_PACKAGE_PROFILING_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.profiling:framework-profiling
    ifeq ($(RELEASE_ANOMALY_DETECTOR),true)
        PRODUCT_APEX_BOOT_JARS += \
            com.android.profiling:framework-anomaly-detector
    endif

endif

ifneq (,$(RELEASE_RANGING_STACK))
    PRODUCT_APEX_BOOT_JARS += \
        com.android.uwb:framework-ranging \
    $(call soong_config_set,bootclasspath,release_ranging_stack,true)
endif

ifeq ($(RELEASE_TELECOM_MAINLINE_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.telephonycore:framework-telecom \

else
    PRODUCT_BOOT_JARS += \
        framework-telecom \

endif

ifeq ($(RELEASE_TELEPHONY_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.telephonycore:framework-telephony \

else
    PRODUCT_BOOT_JARS += \
        framework-platformtelephony \

endif

ifeq ($(RELEASE_WEBAPP_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.webapp:framework-webapp \

endif

ifeq ($(RELEASE_NPUMANAGER_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.npumanager:framework-npumanager \

endif

ifeq ($(RELEASE_UPROBESTATS_BRIDGE_SERVICE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.uprobestats:framework-uprobestats \

endif

ifeq ($(RELEASE_BETTERTOGETHER_MODULE),true)
    PRODUCT_APEX_BOOT_JARS += \
        com.android.bettertogether:framework-bettertogether \

endif

# List of system_server classpath jars delivered via apex.
# Keep the list sorted by module names and then library names.
# Note: For modules available in Q, DO NOT add new entries here.
PRODUCT_APEX_SYSTEM_SERVER_JARS := \
    com.android.adservices:service-adservices \
    com.android.adservices:service-sdksandbox \
    com.android.appsearch:service-appsearch \
    com.android.art:service-art \
    com.android.configinfrastructure:service-configinfrastructure \
    com.android.crashrecovery:service-crashrecovery \
    com.android.healthfitness:service-healthfitness \
    com.android.media:service-media-s \
    com.android.ondevicepersonalization:service-ondevicepersonalization \
    com.android.permission:service-permission \
    com.android.rkpd:service-rkp \

# When we release ondeviceintelligence in NeuralNetworks module
ifeq ($(RELEASE_ONDEVICE_INTELLIGENCE_MODULE),true)
    PRODUCT_APEX_SYSTEM_SERVER_JARS += \
        com.android.neuralnetworks:service-ondeviceintelligence

endif

# When we release npumanager module
ifeq ($(RELEASE_NPUMANAGER_MODULE),true)
    PRODUCT_APEX_SYSTEM_SERVER_JARS += \
        com.android.npumanager:service-npumanager \

endif

ifeq ($(RELEASE_TELECOM_MAINLINE_MODULE),true)
    PRODUCT_APEX_SYSTEM_SERVER_JARS += \
        com.android.telephonycore:service-telecom \

endif

ifeq ($(RELEASE_AVF_ENABLE_LLPVM_CHANGES),true)
  PRODUCT_APEX_SYSTEM_SERVER_JARS += com.android.virt:service-virtualization
endif

# List of jars on the platform that system_server loads dynamically using separate classloaders.
# Keep the list sorted library names.
PRODUCT_STANDALONE_SYSTEM_SERVER_JARS := \

# List of jars delivered via apex that system_server loads dynamically using separate classloaders.
# Keep the list sorted by module names and then library names.
# Note: For modules available in Q, DO NOT add new entries here.
# The Soong modules for these jars should inherit standalone-system-server-module-optimize-defaults.
PRODUCT_APEX_STANDALONE_SYSTEM_SERVER_JARS := \
    com.android.bt:service-bluetooth \
    com.android.devicelock:service-devicelock \
    com.android.os.statsd:service-statsd \
    com.android.scheduling:service-scheduling \
    com.android.tethering:service-connectivity \
    com.android.uwb:service-uwb \
    com.android.wifi:service-wifi \

# Check if build supports Profiling module.
ifeq ($(RELEASE_PACKAGE_PROFILING_MODULE),true)
    PRODUCT_APEX_STANDALONE_SYSTEM_SERVER_JARS += \
        com.android.profiling:service-profiling
    ifeq ($(RELEASE_ANOMALY_DETECTOR),true)
        PRODUCT_APEX_SYSTEM_SERVER_JARS += \
            com.android.profiling:service-anomaly-detector
    endif
endif

ifneq (,$(RELEASE_RANGING_STACK))
    PRODUCT_APEX_STANDALONE_SYSTEM_SERVER_JARS += \
        com.android.uwb:service-ranging
endif

ifeq ($(RELEASE_UPROBESTATS_BRIDGE_SERVICE),true)
    PRODUCT_APEX_STANDALONE_SYSTEM_SERVER_JARS += \
        com.android.uprobestats:service-uprobestats-bridge
endif

ifeq ($(RELEASE_BETTERTOGETHER_MODULE),true)
    PRODUCT_APEX_STANDALONE_SYSTEM_SERVER_JARS += \
        com.android.bettertogether:service-device-to-device
    PRODUCT_APEX_SYSTEM_SERVER_JARS += \
        com.android.bettertogether:service-device-to-device
endif

# Overrides the (apex, jar) pairs above when determining the on-device location. The format is:
# <old_apex>:<old_jar>:<new_apex>:<new_jar>
PRODUCT_CONFIGURED_JAR_LOCATION_OVERRIDES := \
    platform:framework-minus-apex:platform:framework \
    platform:core-icu4j-host:com.android.i18n:core-icu4j \
    platform:conscrypt-host:com.android.conscrypt:conscrypt \

# Minimal configuration for running dex2oat (default argument values).
# PRODUCT_USES_DEFAULT_ART_CONFIG must be true to enable boot image compilation.
PRODUCT_USES_DEFAULT_ART_CONFIG := true
PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.image-dex2oat-Xms=64m \
    dalvik.vm.image-dex2oat-Xmx=512m \
    dalvik.vm.dex2oat-Xms=64m \
    dalvik.vm.dex2oat-Xmx=512m \
