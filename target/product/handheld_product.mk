#
# Copyright (C) 2019 The Android Open Source Project
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

# This makefile contains the product partition contents for
# a generic phone or tablet device. Only add something here if
# it definitely doesn't belong on other types of devices (if it
# does, use base_product.mk).
$(call inherit-product, $(SRC_TARGET_DIR)/product/media_product.mk)

# /product packages
PRODUCT_PACKAGES += \
    Browser2 \
    Calendar \
<<<<<<< PATCH SET (feaa5dc378efd73cef1bdf4d7363b8ababeaf5dd build: Move Contacts to telephony_product.mk)
=======
    Camera2 \
    Contacts \
>>>>>>> BASE      (e7cc87a995b25ae412aefa493d2b9c2b0157f29d releasetools: skip disable_ublk on non-dynamic devices)
    DeskClock \
    Gallery2 \
    Music \
    preinstalled-packages-platform-handheld-product.xml \
    QuickSearchBox \
    SettingsIntelligence \
    frameworks-base-overlays

ifeq ($(LINEAGE_BUILD),)
PRODUCT_PACKAGES += \
    LatinIME
endif

PRODUCT_PACKAGES_DEBUG += \
    frameworks-base-overlays-debug
