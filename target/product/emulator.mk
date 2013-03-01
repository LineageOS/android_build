#
# Copyright (C) 2012 The Android Open Source Project
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
# This file is included by other product makefiles to add all the
# emulator-related host modules to PRODUCT_PACKAGES.
#

PRODUCT_PACKAGES += \
	emulator \
	emulator-x86 \
	emulator-arm \
	emulator-mips \
	emulator64-x86 \
	emulator64-arm \
	emulator64-mips \
	libOpenglRender \
	libGLES_CM_translator \
	libGLES_V2_translator \
	libEGL_translator \
	lib64OpenglRender \
	lib64GLES_CM_translator \
	lib64GLES_V2_translator \
	lib64EGL_translator

PRODUCT_PACKAGES += \
    egl.cfg \
    gles_emul.cfg \
    libGLESv1_CM_emul \
    libGLESv2_emul \
    libEGL_emul \
    libut_rendercontrol_enc \
    gralloc.goldfish \
    libGLESv1_CM_emulation \
    lib_renderControl_enc \
    libEGL_emulation \
    libGLESv2_enc \
    libOpenglSystemCommon \
    libGLESv2_emulation \
    libGLESv1_enc \
    qemu-props \
    qemud \
    camera.goldfish \
    lights.goldfish \
    gps.goldfish \
    sensors.goldfish
