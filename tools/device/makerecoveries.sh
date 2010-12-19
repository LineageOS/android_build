if [ -z "$1" ]
then
    echo "Please provide a version number."
    return
fi

if [ -z "$2" ]
then
    PRODUCTS='koush_aloha-eng koush_pulse-eng koush_buzz-eng koush_streak-eng koush_espresso-eng koush_legend-eng koush_pulsemini-eng koush_liberty-eng koush_inc-eng koush_supersonic-eng koush_bravo-eng koush_dream-eng koush_sapphire-eng koush_passion-eng koush_sholes-eng koush_magic-eng koush_hero-eng koush_heroc-eng koush_desirec-eng'
else
    PRODUCTS=$2
fi

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
    mcpguard $OUT/recovery.img recoveries/recovery-clockwork-$1-$DEVICE_NAME.img

    . build/tools/device/mkrecoveryzip.sh $1
    mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$DEVICE_NAME.zip

    ALL_DEVICES=$DEVICE_NAME

    if [ $DEVICE_NAME == "sholes" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$1-milestone.zip
        ALL_DEVICES=$ALL_DEVICES' milestone'
    fi

    if [ $DEVICE_NAME == "tab" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$1-tmobile_tab.zip
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$1-att_tab.zip
        ALL_DEVICES=$ALL_DEVICES' tmobile_tab att_tab'
    fi
    
    if [ $DEVICE_NAME == "galaxys" ]
    then
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$1-vibrant.zip
        mcpguard $OUT/utilities/update.zip recoveries/recovery-clockwork-$1-captivate.zip
        ALL_DEVICES=$ALL_DEVICES' vibrant captivate'
    fi
    
    if [ -f ~/.rommanager_api_key ]
    then
        for device in $ALL_DEVICES
        do
            curl 'https://rommanager.appspot.com/api/updateDevice?apikey='$(cat ~/.rommanager_api_key)'&board='$device'&version='$1
        done
    fi
done

for published_recovery in $PUBLISHED_RECOVERIES
do
    echo $published_recovery
done

