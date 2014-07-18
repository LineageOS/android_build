#!/bin/sh

# Copyright (C) 2014 The OmniROM Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This works, but there has to be a better way of reliably getting the root build directory...
if [ $# -eq 1 ]; then
    TOP=$1
    DEVICE=$TARGET_DEVICE
elif [ -n "$(gettop)" ]; then
    TOP=$(gettop)
    DEVICE=$(get_build_var TARGET_DEVICE)
else
    echo "Please run envsetup.sh and lunch before running this script,"
    echo "or provide the build root directory as the first parameter."
    return 1
fi

TARGET_DIR=$OUT
PREBUILT_DIR=$TOP/prebuilts/chromium/$DEVICE

if [ -d $PREBUILT_DIR ]; then
    rm -rf $PREBUILT_DIR
fi

mkdir -p $PREBUILT_DIR
mkdir -p $PREBUILT_DIR/framework
mkdir -p $PREBUILT_DIR/lib

if [ -d $TARGET_DIR ]; then
    echo "Copying files..."
    cp -r $TARGET_DIR/system/framework/webview $PREBUILT_DIR/framework/
    cp $TARGET_DIR/system/lib/libwebviewchromium.so $PREBUILT_DIR/lib/libwebviewchromium.so
    cp $TARGET_DIR/../../common/obj/JAVA_LIBRARIES/android_webview_java_intermediates/javalib.jar $PREBUILT_DIR/android_webview_java.jar
else
    echo "Please ensure that you have ran a full build prior to running this script!"
    return 1;
fi

echo "Generating Makefiles..."

HASH=$(git --git-dir=$TOP/external/chromium/.git --work-tree=$TOP/external/chromium rev-parse --verify HEAD)
echo $HASH > $PREBUILT_DIR/hash.txt

(cat << EOF) | sed s/__DEVICE__/$DEVICE/g > $PREBUILT_DIR/chromium_prebuilt.mk
# Copyright (C) 2014 The MoKee OpenSource Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := prebuilts/chromium/__DEVICE__/

PRODUCT_COPY_FILES += \\
    \$(LOCAL_PATH)/framework/webview/paks/am.pak:system/framework/webview/paks/am.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ar.pak:system/framework/webview/paks/ar.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/bg.pak:system/framework/webview/paks/bg.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/bn.pak:system/framework/webview/paks/bn.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ca.pak:system/framework/webview/paks/ca.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/cs.pak:system/framework/webview/paks/cs.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/da.pak:system/framework/webview/paks/da.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/de.pak:system/framework/webview/paks/de.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/el.pak:system/framework/webview/paks/el.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/en-GB.pak:system/framework/webview/paks/en-GB.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/en-US.pak:system/framework/webview/paks/en-US.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/es.pak:system/framework/webview/paks/es.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/es-419.pak:system/framework/webview/paks/es-419.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/et.pak:system/framework/webview/paks/et.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/fa.pak:system/framework/webview/paks/fa.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/fi.pak:system/framework/webview/paks/fi.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/fil.pak:system/framework/webview/paks/fil.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/fr.pak:system/framework/webview/paks/fr.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/gu.pak:system/framework/webview/paks/gu.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/he.pak:system/framework/webview/paks/he.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/hi.pak:system/framework/webview/paks/hi.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/hr.pak:system/framework/webview/paks/hr.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/hu.pak:system/framework/webview/paks/hu.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/id.pak:system/framework/webview/paks/id.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/it.pak:system/framework/webview/paks/it.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ja.pak:system/framework/webview/paks/ja.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/kn.pak:system/framework/webview/paks/kn.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ko.pak:system/framework/webview/paks/ko.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/lt.pak:system/framework/webview/paks/lt.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/lv.pak:system/framework/webview/paks/lv.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ml.pak:system/framework/webview/paks/ml.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/mr.pak:system/framework/webview/paks/mr.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ms.pak:system/framework/webview/paks/ms.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/nb.pak:system/framework/webview/paks/nb.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/nl.pak:system/framework/webview/paks/nl.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/pl.pak:system/framework/webview/paks/pl.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/pt-BR.pak:system/framework/webview/paks/pt-BR.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/pt-PT.pak:system/framework/webview/paks/pt-PT.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ro.pak:system/framework/webview/paks/ro.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ru.pak:system/framework/webview/paks/ru.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/sk.pak:system/framework/webview/paks/sk.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/sl.pak:system/framework/webview/paks/sl.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/sr.pak:system/framework/webview/paks/sr.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/sv.pak:system/framework/webview/paks/sv.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/sw.pak:system/framework/webview/paks/sw.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/ta.pak:system/framework/webview/paks/ta.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/te.pak:system/framework/webview/paks/te.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/th.pak:system/framework/webview/paks/th.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/tr.pak:system/framework/webview/paks/tr.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/uk.pak:system/framework/webview/paks/uk.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/vi.pak:system/framework/webview/paks/vi.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/webviewchromium.pak:system/framework/webview/paks/webviewchromium.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/zh-CN.pak:system/framework/webview/paks/zh-CN.pak \\
    \$(LOCAL_PATH)/framework/webview/paks/zh-TW.pak:system/framework/webview/paks/zh-TW.pak \\
    \$(LOCAL_PATH)/lib/libwebviewchromium.so:system/lib/libwebviewchromium.so

EOF

echo "Done!"
