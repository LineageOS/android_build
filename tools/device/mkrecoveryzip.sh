#!/bin/bash

# Build 2 sets of zip's.  One that uses the update.img file and one that attempt
# to in-place update the existing update partition.  "so that devices that are
# unable to flash the recovery partition can still run it by replacing the stock
# partition during runtime."

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

#build Recovery flash update package. ...
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
java -jar $SIGNAPK -w $ANDROID_ROOT/build/target/product/security/testkey.x509.pem $ANDROID_ROOT/build/target/product/security/testkey.pk8 $OUT/unsigned.zip $OUT/update.zip

echo Recovery is now available at $OUT/update.zip
# clean up for the fake update build.
rm -rf META-INF recovery.img

#
#build Recovery FakeFlash update package...
#

cp -R $OUT/recovery/root/etc etc
cp -R $OUT/recovery/root/sbin sbin
cp -R $OUT/recovery/root/res res
SCRIPT_DIR=META-INF/com/google/android
mkdir -p $SCRIPT_DIR
cp $OUT/system/bin/updater $SCRIPT_DIR/update-binary


UPDATER_SCRIPT=$SCRIPT_DIR/updater-script
rm -f $UPDATER_SCRIPT
touch $UPDATER_SCRIPT
mkdir -p $(dirname $UPDATER_SCRIPT)

FILES=
SYMLINKS=

for file in $(find .)
do

if [ -d $file ]
then
  continue
fi

META_INF=$(echo $file | grep META-INF)
if [ ! -z $META_INF ]
then
    continue;
fi

if [ -h $file ]
then
    SYMLINKS=$SYMLINKS' '$file
elif [ -f $file ]
then
    FILES=$FILES' '$file
fi
done


echo 'ui_print("Replacing stock recovery with ClockworkMod recovery...");' >> $UPDATER_SCRIPT

echo 'delete("sbin/recovery");' >> $UPDATER_SCRIPT
echo 'package_extract_file("sbin/recovery", "/sbin/recovery");' >> $UPDATER_SCRIPT
echo 'set_perm(0, 0, 0755, "/sbin/recovery");' >> $UPDATER_SCRIPT
echo 'symlink("recovery", "/sbin/busybox");' >> $UPDATER_SCRIPT

echo 'run_program("/sbin/busybox", "sh", "-c", "busybox rm -f /etc ; busybox mkdir -p /etc;");' >> $UPDATER_SCRIPT

for file in $FILES
do
    echo 'delete("'$(echo $file | sed s!\\./!!g)'");' >> $UPDATER_SCRIPT
    echo 'package_extract_file("'$(echo $file | sed s!\\./!!g)'", "'$(echo $file | sed s!\\./!/!g)'");' >> $UPDATER_SCRIPT
    if [ -x $file ]
    then
        echo 'set_perm(0, 0, 0755, "'$(echo $file | sed s!\\./!/!g)'");' >> $UPDATER_SCRIPT
    fi
done

for file in $SYMLINKS
do
    echo 'symlink("'$(readlink $file)'", "'$(echo $file | sed s!\\./!/!g)'");' >> $UPDATER_SCRIPT
done

echo 'set_perm_recursive(0, 2000, 0755, 0755, "/sbin");' >> $UPDATER_SCRIPT
echo 'run_program("/sbin/busybox", "sh", "-c", "/sbin/killrecovery.sh");' >> $UPDATER_SCRIPT
rm -f $UTILITIES_DIR/unsigned.zip
rm -f $UTILITIES_DIR/update.zip
echo zip -ry $UTILITIES_DIR/unsigned.zip . -x $SYMLINKS '*\[*' '*\[\[*'
zip -ry $UTILITIES_DIR/unsigned.zip . -x $SYMLINKS '*\[*' '*\[\[*'
java -jar $SIGNAPK -w $ANDROID_ROOT/build/target/product/security/testkey.x509.pem $ANDROID_ROOT/build/target/product/security/testkey.pk8 $UTILITIES_DIR/unsigned.zip $UTILITIES_DIR/update.zip

echo Recovery FakeFlash is now available at $OUT/utilities/update.zip
popd > /dev/null 2> /dev/null
