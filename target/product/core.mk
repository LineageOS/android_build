PRODUCT_BRAND :=
PRODUCT_NAME :=
PRODUCT_DEVICE :=
PRODUCT_POLICY := android.policy_phone

ifneq ($(NO_DEFAULT_SOUNDS),true)
PRODUCT_PROPERTY_OVERRIDES := \
    ro.config.notification_sound=OnTheHunt.ogg \
    ro.config.alarm_alert=Alarm_Classic.ogg
endif

PRODUCT_PACKAGES := \
    framework-res \
    Browser \
    Contacts \
    Launcher \
    HTMLViewer \
    Phone \
    ApplicationsProvider \
    ContactsProvider \
    DownloadProvider \
    GoogleSearch \
    MediaProvider \
    PicoTts \
    SettingsProvider \
    TelephonyProvider \
    TtsService \
    VpnServices \
    UserDictionaryProvider \
    PackageInstaller \
    Bugreport
