#
# Copyright (C) 2018 The Android Open Source Project
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

# Base modules and settings for the system partition.
#
# When adding a module to this list, you must also add it to the deps of the system_image_defaults
# module in target/product/generic/Android.bp. See tools/filelistdiff/README.md for more details.
#
# LINT.IfChange
PRODUCT_PACKAGES += \
    abx \
    aconfigd-system \
    adbd_system_api \
    aflags \
    am \
    android.hidl.base-V1.0-java \
    android.hidl.manager-V1.0-java \
    android.system.suspend-service \
    android.test.base \
    android.test.mock \
    android.test.runner \
    aoad \
    apexd \
    apexd.mainline_patch_level_2 \
    app-lock-exempt.xml \
    appops \
    app_process \
    appwidget \
    atrace \
    audioserver \
    BackupRestoreConfirmation \
    bcc \
    blank_screen \
    blkid \
    bmgr \
    bootanimation \
    bootstat \
    boringssl_self_test \
    bpfloader \
    bu \
    bugreport \
    bugreportz \
    build_flag_system \
    casefolding_remover \
    cgroups.json \
    charger \
    cmd \
    com.android.adbd \
    com.android.adservices \
    com.android.appsearch \
    com.android.bt \
    com.android.configinfrastructure \
    com.android.conscrypt \
    com.android.crashrecovery \
    com.android.devicelock \
    com.android.extservices \
    com.android.healthfitness \
    com.android.i18n \
    com.android.ipsec \
    com.android.location.provider \
    com.android.media \
    com.android.media.swcodec \
    com.android.mediaprovider \
    com.android.ondevicepersonalization \
    com.android.os.statsd \
    com.android.permission \
    com.android.resolv \
    com.android.rkpd \
    com.android.neuralnetworks \
    com.android.scheduling \
    com.android.sdkext \
    com.android.tethering \
    $(RELEASE_PACKAGE_TZDATA_MODULE) \
    com.android.uprobestats \
    com.android.uwb \
    com.android.virt \
    com.android.wifi \
    ContactsProvider \
    content \
    CtsShimPrebuilt \
    CtsShimPrivPrebuilt \
    debuggerd\
    device_config \
    dmctl \
    dnsmasq \
    dmesgd \
    DownloadProvider \
    dpm \
    dump.erofs \
    dumpstate \
    dumpsys \
    E2eeContactKeysProvider \
    e2fsck \
    enhanced-confirmation.xml \
    evemu-record \
    ExtShared \
    flags_health_check \
    framework-graphics \
    framework-location \
    framework-minus-apex \
    framework-minus-apex-install-dependencies \
    framework-sysconfig.xml \
    fsck.erofs \
    fsck_msdos \
    fs_config_files_system \
    fs_config_dirs_system \
    gpu_counter_producer \
    group_system \
    gsid \
    gsi_tool \
    heapprofd \
    heapprofd_client \
    hidservice \
    gatekeeperd \
    gpuservice \
    hid \
    idmap2 \
    idmap2d \
    ime \
    ims-common \
    incident \
    incidentd \
    incident_helper \
    incident-helper-cmd \
    init.environ.rc \
    init_system \
    initial-package-stopped-states.xml \
    input \
    installd \
    IntentResolver \
    ip \
    iptables \
    javax.obex \
    kcmdlinectrl \
    kcmdlinemodprobe \
    keystore2 \
    credstore \
    ld.mc \
    libaaudio \
    libalarm_jni \
    libamidi \
    libandroid \
    libandroidfw \
    libandroid_runtime \
    libandroid_servers \
    libartpalette-system \
    libaudioeffect_jni \
    libbinder \
    libbinder_ndk \
    libbinder_rpc_unstable \
    libcamera2ndk \
    libcutils \
    libdrmframework \
    libdrmframework_jni \
    libEGL \
    libETC1 \
    libfdtrack \
    libFFTEm \
    libfilterfw \
    libgatekeeper \
    libGLESv1_CM \
    libGLESv2 \
    libGLESv3 \
    libgui \
    libhardware \
    libhardware_legacy \
    libincident \
    libinput \
    libinputflinger \
    libiprouteutil \
    libjnigraphics \
    libjpeg \
    liblog \
    libmedia \
    libmedia_jni \
    libmediandk \
    libmonkey_jni \
    libmtp \
    libnetd_client \
    libnetlink \
    libnetutils \
    libneuralnetworks_packageinfo \
    libOpenMAXAL \
    libOpenSLES \
    libpdfium \
    libpower \
    libpowermanager \
    libradio_metadata \
    librtp_jni \
    libsensorservice \
    libsfplugin_ccodec \
    libskia \
    libsonic \
    libsonivox \
    libsoundpool \
    libspeexresampler \
    libsqlite \
    libstagefright \
    libstagefright_foundation \
    libstagefright_omx \
    libstdc++ \
    libsysutils \
    libui \
    libusbhost \
    libutils \
    libvintf_jni \
    libvulkan \
    libwilhelm \
    llkd \
    llndk_libs \
    lmkd \
    LocalTransport \
    locksettings \
    logcat \
    logd \
    lpdump \
    lshal \
    mdnsd \
    mediacodec.policy \
    mediacodeclist_generator \
    mediaextractor \
    media_profiles_V1_0.dtd \
    mediaserver \
    mke2fs \
    mkfs.erofs \
    mm_daemon \
    mm_daemon_setup \
    monkey \
    misctrl \
    mtectrl \
    ndc \
    netd \
    NetworkStack \
    odsign \
    org.apache.http.legacy \
    otacerts \
    PackageInstaller \
    package-shareduid-allowlist.xml \
    passwd_system \
    pbtombstone \
    perfetto \
    perfetto-extras \
    ping \
    ping6 \
    pintool \
    platform.xml \
    pm \
    prefetch \
    preinstalled-packages-asl-files.xml \
    preinstalled-packages-platform.xml \
    preinstalled-packages-strict-signature.xml \
    privapp-permissions-platform.xml \
    prng_seeder \
    recovery-persist \
    resize2fs \
    rss_hwm_reset \
    run-as \
    sanitizer.libraries.txt \
    schedtest \
    screencap \
    sdcard \
    secdiscard \
    selinux_policy_system \
    sensorservice \
    service \
    servicemanager \
    services \
    settings \
    SettingsProvider \
    sfdo \
    sgdisk \
    Shell \
    shell_and_utilities_system \
    sm \
    snapuserd \
    storaged \
    surfaceflinger \
    svc \
    system-build.prop \
    task_profiles.json \
    tc \
    telephony-common \
    tombstoned \
    traced \
    traced_probes \
    tradeinmode \
    tune2fs \
    uiautomator \
    uinput \
    uncrypt \
    usbd \
    vdc \
    vintf \
    voip-common \
    vold \
    watchdogd \
    wifi.rc \
    wm \
# LINT.ThenChange(/target/product/generic/Android.bp)

ifeq ($(RELEASE_CROSS_DEVICE_SYNC),true)
  PRODUCT_PACKAGES += \
        CrossDeviceSync
endif

# This is the telecom cmd binary, NOT Telecom APK.
PRODUCT_PACKAGES += \
    telecom

# Once framework-telecom is APEX, the code will be included there.
ifneq ($(RELEASE_TELECOM_MAINLINE_MODULE),true)
  PRODUCT_PACKAGES += \
      framework-telecom

endif

# When we release ondeviceintelligence in neuralnetworks module
ifneq ($(RELEASE_ONDEVICE_INTELLIGENCE_MODULE),true)
  PRODUCT_PACKAGES += \
        framework-ondeviceintelligence-platform

endif

# Non-updatable NSC classes. Replaced by framework-conscrypt-nsc.
ifneq ($(RELEASE_CONSCRYPT_NSC),true)
  PRODUCT_PACKAGES += \
        framework-network-security-config \

endif

# These packages are not used on Android TV
ifneq ($(PRODUCT_IS_ATV),true)
  PRODUCT_PACKAGES += \
      $(RELEASE_PACKAGE_SOUND_PICKER) \

endif

# Product does not support Dynamic System Update
ifneq ($(PRODUCT_NO_DYNAMIC_SYSTEM_UPDATE),true)
    PRODUCT_PACKAGES += \
        DynamicSystemInstallationService \

endif

# Check if the build supports NFC apex or not
ifeq ($(RELEASE_PACKAGE_NFC_STACK),NfcNci)
    PRODUCT_PACKAGES += \
        framework-nfc \
        NfcNci
else
    PRODUCT_PACKAGES += \
        com.android.nfcservices
endif

# Check if the build supports Profiling module
ifeq ($(RELEASE_PACKAGE_PROFILING_MODULE),true)
    PRODUCT_PACKAGES += \
       com.android.profiling
endif

ifeq ($(RELEASE_USE_WEBVIEW_BOOTSTRAP_MODULE),true)
    PRODUCT_PACKAGES += \
        com.android.webview.bootstrap
endif

ifeq ($(RELEASE_TELEPHONY_MODULE),true)
    PRODUCT_PACKAGES += \
       com.android.telephonycore

else
    PRODUCT_PACKAGES += \
        framework-platformtelephony
endif

ifeq ($(RELEASE_NPUMANAGER_MODULE),true)
    PRODUCT_PACKAGES += \
       com.android.npumanager \
       libnpumanager
endif

ifeq ($(RELEASE_WEBAPP_MODULE),true)
    PRODUCT_PACKAGES += \
       com.android.webapp
endif

ifeq ($(RELEASE_BETTERTOGETHER_MODULE),true)
    PRODUCT_PACKAGES += \
       com.android.bettertogether
endif

# include in framework regardless of flag, so that we have overlap
# while moving from framework to module in the event of a module mismatch.
# the relevant mediametrics.*rc files properly handle presence of both.
ifeq ($(RELEASE_MEDIAMETRICS_MODULE),true)
    PRODUCT_PACKAGES += \
        mediametrics
else
    PRODUCT_PACKAGES += \
        mediametrics
endif

ifeq ($(RELEASE_PROCESS_MEMORY_GUARDIAN_DAEMON),true)
  PRODUCT_PACKAGES += \
        pmg_daemon
endif

# VINTF data for system image
PRODUCT_PACKAGES += \
    system_manifest.xml \
    system_compatibility_matrix.xml \

# hwservicemanager is now installed on system_ext, but apexes might be using
# old libraries that are expecting it to be installed on system. This allows
# those apexes to continue working. The symlink can be removed once we are sure
# there are no devices using hwservicemanager (when Android V launching devices
# are no longer supported for dessert upgrades).
PRODUCT_PACKAGES += \
    hwservicemanager_compat_symlink_module \

# wificond is now installed on system_ext, but some callers may still expect
# it to be installed on system. This symlink can be removed once we are sure
# that there are no devices using wificond.
PRODUCT_PACKAGES += \
    wificond_compat_symlink_module \

# Prevent timeouts to check availability of hwservicmanager during boot
PRODUCT_SYSTEM_PROPERTIES += hwservicemanager.always_sets_disabled=true

PRODUCT_PACKAGES_ARM64 := libclang_rt.hwasan \
 libc_hwasan \

# Bionic
ifeq ($(RELEASE_DEPRECATE_RUNTIME_APEX),true)
PRODUCT_PACKAGES += \
    libc \
    libdl \
    libm \
    libdl_android \
    linker \
    linkerconfig \
    crash_dump
else
PRODUCT_PACKAGES += \
    libc.bootstrap \
    libdl.bootstrap \
    libm.bootstrap \
    libdl_android.bootstrap \
    linker
PRODUCT_PACKAGES_ARM64 += \
    libclang_rt.hwasan.bootstrap
endif # RELEASE_DEPRECATE_RUNTIME_APEX

# Jacoco agent JARS to be built and installed, if any.
ifeq ($(EMMA_INSTRUMENT),true)
  ifneq ($(EMMA_INSTRUMENT_STATIC),true)
    # For instrumented build, if Jacoco is not being included statically
    # in instrumented packages then include Jacoco classes in the product
    # packages.
    PRODUCT_PACKAGES += jacocoagent
    ifneq ($(EMMA_INSTRUMENT_FRAMEWORK),true)
      # For instrumented build, if Jacoco is not being included statically
      # in instrumented packages and has not already been included in the
      # bootclasspath via ART_APEX_JARS then include Jacoco classes into the
      # bootclasspath.
      PRODUCT_BOOT_JARS += jacocoagent
    endif # EMMA_INSTRUMENT_FRAMEWORK
  endif # EMMA_INSTRUMENT_STATIC
endif # EMMA_INSTRUMENT

ifeq (,$(DISABLE_WALLPAPER_BACKUP))
  PRODUCT_PACKAGES += \
    WallpaperBackup
endif

PRODUCT_PACKAGES += \
    libEGL_angle \
    libGLESv1_CM_angle \
    libGLESv2_angle

# For testing purposes
ifeq ($(FORCE_AUDIO_SILENT), true)
    PRODUCT_SYSTEM_PROPERTIES += ro.audio.silent=1
endif

# Host tools to install
PRODUCT_HOST_PACKAGES += \
    BugReport \
    adb \
    adevice \
    atest \
    bcc \
    bit \
    dump.erofs \
    e2fsck \
    fastboot \
    flags_health_check \
    fsck.erofs \
    icu-data_host_i18n_apex \
    tzdata_icu_res_files_host_prebuilts \
    idmap2 \
    incident_report \
    ld.mc \
    lpdump \
    mke2fs \
    mkfs.erofs \
    pbtombstone \
    resize2fs \
    sgdisk \
    sqlite3 \
    tinyplay \
    tune2fs \
    unwind_info \
    unwind_reg_info \
    unwind_symbols \
    tzdata_host \
    tzdata_host_tzdata_apex \
    tzlookup.xml_host_tzdata_apex \
    tz_version_host \
    tz_version_host_tzdata_apex \

# For art-tools, if the dependencies have changed, please sync them to art/Android.bp as well.
PRODUCT_HOST_PACKAGES += \
    ahat \
    dexdump \
    hprof-conv
# A subset of the tools are disabled when HOST_PREFER_32_BIT is defined as make reports that
# they are not supported on host (b/129323791). This is likely due to art_apex disabling host
# APEX builds when HOST_PREFER_32_BIT is set (b/120617876).
ifneq ($(HOST_PREFER_32_BIT),true)
PRODUCT_HOST_PACKAGES += \
    dexlist \
    oatdump
endif


PRODUCT_PACKAGES += init.usb.rc init.usb.configfs.rc

PRODUCT_PACKAGES += etc_hosts

PRODUCT_PACKAGES += init.zygote32.rc

PRODUCT_SYSTEM_PROPERTIES += debug.atrace.tags.enableflags=0
PRODUCT_SYSTEM_PROPERTIES += persist.traced.enable=1
PRODUCT_SYSTEM_PROPERTIES += ro.surface_flinger.game_default_frame_rate_override=60
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.enabled=0
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.max_log_files=10
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.max_log_file_size_kb=10240
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.batching.enabled=1
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.batching.max_batch_size=100
PRODUCT_SYSTEM_PROPERTIES += persist.pcc.audit_mode.batching.flush_time_ms=10000

# When the flag RELEASE_ADBD_OPEN_VSOCK_PORT is enabled, open adbd on vsock port 8382 as default.
ifneq ($(RELEASE_ADBD_OPEN_VSOCK_PORT),)
PRODUCT_SYSTEM_PROPERTIES += service.adb.listen_addrs?=vsock:8382
endif

# Include kernel configs.
PRODUCT_PACKAGES += \
    approved-ogki-builds.xml \
    kernel-lifetimes.xml

# Packages included only for eng or userdebug builds, previously debug tagged
PRODUCT_PACKAGES_DEBUG := \
    adevice_fingerprint \
    arping \
    dmuserd \
    idlcli \
    init-debug.rc \
    iotop \
    iperf3 \
    iw \
    layertracegenerator \
    libclang_rt.ubsan_standalone \
    logpersist.start \
    logtagd.rc \
    lpmodify \
    ot-cli-ftd \
    ot-ctl \
    overlay_remounter \
    procrank \
    profcollectd \
    profcollectctl \
    record_binder \
    servicedispatcher \
    showmap \
    snapshotctl \
    sqlite3 \
    ss \
    start_with_lockagent \
    strace \
    sanitizer-status \
    tracepath \
    tracepath6 \
    traceroute6 \
    unwind_info \
    unwind_reg_info \
    unwind_symbols \

ifeq ($(LINEAGE_BUILD),)
PRODUCT_PACKAGES_DEBUG += \
    su
endif

# The set of packages whose code can be loaded by the system server.
PRODUCT_SYSTEM_SERVER_APPS += \
    SettingsProvider \

ifeq (,$(DISABLE_WALLPAPER_BACKUP))
  PRODUCT_SYSTEM_SERVER_APPS += \
    WallpaperBackup
endif

PRODUCT_PACKAGES_DEBUG_JAVA_COVERAGE := \
    libdumpcoverage

PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
    frameworks/base/config/preloaded-classes:system/etc/preloaded-classes)

# Enable dirty image object binning to reduce dirty pages in the image.
PRODUCT_PACKAGES += dirty-image-objects

# Enable go/perfetto-persistent-tracing for eng builds
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
    PRODUCT_PRODUCT_PROPERTIES += persist.debug.perfetto.persistent_sysui_tracing_for_bugreport=1
endif

ifneq (,$(RELEASE_NATIVE_FRAMEWORK_PROTOTYPE))
    PRODUCT_PACKAGES += \
        libandroid_native_denylist \
        zygote_next
endif

# Whether to use Java or new native (Rust) OMAPI implementation
ifeq ($(RELEASE_NATIVE_OMAPI),true)
    PRODUCT_PACKAGES += \
        omapi
else
    PRODUCT_PACKAGES += \
        SecureElement
endif

ifneq (,$(RELEASE_AISEAL_FRAMEWORK))
    PRODUCT_PACKAGES += \
        aisealhostservice \
        AppSearchAiSealConfig
endif

$(call inherit-product, $(SRC_TARGET_DIR)/product/runtime_libart.mk)

# Ensure all trunk-stable flags are available.
$(call inherit-product, $(SRC_TARGET_DIR)/product/build_variables.mk)

# Use "image" APEXes always.
$(call inherit-product,$(SRC_TARGET_DIR)/product/updatable_apex.mk)

$(call soong_config_set, bionic, large_system_property_node, $(RELEASE_LARGE_SYSTEM_PROPERTY_NODE))
$(call soong_config_set, Aconfig, read_from_new_storage, $(RELEASE_READ_FROM_NEW_STORAGE))
