#!/bin/bash

OUT=$1
SIGNAPK=$2

if [ -z "$OUT" -o -z "$SIGNAPK" ]
then
    echo "Android build environment not detected."
    exit 1
fi

ANDROID_ROOT=$(pwd)
OUT=$ANDROID_ROOT/$OUT
SIGNAPK=$ANDROID_ROOT/$SIGNAPK

pushd . > /dev/null 2> /dev/null

UTILITIES_DIR=$OUT/utilities
mkdir -p $UTILITIES_DIR
RECOVERY_DIR=$UTILITIES_DIR/recovery
rm -rf $RECOVERY_DIR
mkdir -p $RECOVERY_DIR
cd $RECOVERY_DIR

#
#build Recovery flash update package. ...
#

cp $OUT/recovery.img .
SCRIPT_DIR=META-INF/com/google/android
mkdir -p $SCRIPT_DIR
cp $OUT/system/bin/updater $SCRIPT_DIR/update-binary

UPDATER_SCRIPT=$SCRIPT_DIR/updater-script
rm -f $UPDATER_SCRIPT
touch $UPDATER_SCRIPT

echo 'ui_print("Replacing stock recovery with ClockworkMod recovery...");' >> $UPDATER_SCRIPT
echo 'assert(package_extract_file("recovery.img", "/tmp/recovery.img"), write_raw_image("/tmp/recovery.img", "recovery"), delete("/tmp/recovery.img"));' >> $UPDATER_SCRIPT

rm -f $OUT/unsigned.zip
rm -f $OUT/update.zip
echo zip -ry $OUT/unsigned.zip META-INF recovery.img
zip -ry $OUT/unsigned.zip META-INF recovery.img
java -jar $SIGNAPK -w $ANDROID_ROOT/build/target/product/security/testkey.x509.pem $ANDROID_ROOT/build/target/product/security/testkey.pk8 $OUT/unsigned.zip $OUT/update-recovery.zip

echo Recovery is now available at $OUT/update-recovery.zip

popd > /dev/null 2> /dev/null

