if [ -z "$1" ]
then
    echo "Please provide a lunch option."
    return
fi

PRODUCTS=$1

for product in $PRODUCTS
do
    echo $product
done

echo $(echo $PRODUCTS | wc -w) Products

unset PUBLISHED_RECOVERIES

MCP=$(which mcp)
if [ -z "$MCP" ]
then
    NO_UPLOAD=true
fi

function mcpguard () {
    if [ -z $NO_UPLOAD ]
    then
        mcp $1 $2
        md5sum $1 > $1.md5sum.txt
        mcp $1.md5sum.txt $2.md5sum.txt
    fi
}

VERSION=$(cat bootable/recovery/Android.mk | grep RECOVERY_VERSION | grep ClockworkMod | sed s/'RECOVERY_VERSION := ClockworkMod Recovery v'//g)
echo Recovery Version: $VERSION

for lunchoption in $PRODUCTS
do
    lunch $lunchoption
    if [ -z $NO_CLEAN ]
    then
        rm -rf $OUT/obj/EXECUTABLES/recovery_intermediates
        rm -rf $OUT/recovery*
        rm -rf $OUT/root*
    fi
    DEVICE_NAME=$(echo $TARGET_PRODUCT | sed s/koush_// | sed s/aosp_// | sed s/htc_// | sed s/_us// | sed s/cyanogen_// | sed s/generic_// | sed s/full_//)
    PRODUCT_NAME=$(basename $OUT)
    make -j16 recoveryimage out/target/product/$PRODUCT_NAME/system/bin/updater
    RESULT=$?
    if [ $RESULT != "0" ]
    then
        echo build error!
        break
    fi
    mcpguard $OUT/recovery.img recoveries/recovery-clockwork-$VERSION-$DEVICE_NAME.img

    . build/tools/device/mkrecoveryzip.sh $VERSION
    mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-$DEVICE_NAME.zip

    ALL_DEVICES=$DEVICE_NAME

    if [ $DEVICE_NAME == "sholes" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-milestone.zip
        ALL_DEVICES=$ALL_DEVICES' milestone'
    fi

    if [ $DEVICE_NAME == "tab" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-verizon_tab.zip
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-tmobile_tab.zip
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-att_tab.zip
        ALL_DEVICES=$ALL_DEVICES' tmobile_tab att_tab'
    fi
    
    if [ $DEVICE_NAME == "galaxys" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-vibrant.zip
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$VERSION-captivate.zip
        ALL_DEVICES=$ALL_DEVICES' vibrant captivate'
    fi
    
	if [ -f "ROMManagerManifest/devices.rb" ]
	then
		for device in $ALL_DEVICES
		do
			pushd ROMManagerManifest
			ruby devices.rb $device $VERSION
			popd
		done
	fi
done

for published_recovery in $PUBLISHED_RECOVERIES
do
    echo $published_recovery
done

