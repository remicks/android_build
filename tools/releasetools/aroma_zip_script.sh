#!/bin/bash

DEVICE=$1
AROMA_VENDOR_CONFIG=$2
AROMA_VENDOR_SCRIPT=$3
AROMA_ZIP_OUT_FILE=$4
AROMA_DEVICE=$8
SOURCE=$PWD
UPDATER=$OUT/obj/EXECUTABLES/updater_intermediates/updater
AROMADATE=$(date +"%Y-%m-%d")

if [ ! -f "$UPDATER" ]
then
    make updater &>> /dev/null
fi
if [ ! -f "${ANDROID_HOST_OUT}/framework/signapk.jar" ]
then
    make signapk &>> /dev/null
fi

ZIP_DIR=$OUT/Aromazip
mkdir $ZIP_DIR

UPDATER_DIR=$ZIP_DIR/META-INF/com/google/android
mkdir -p $UPDATER_DIR
cp $OUT/obj/EXECUTABLES/updater_intermediates/updater $UPDATER_DIR/update-binary-installer
echo 'if ! is_mounted("/system") then' > $UPDATER_DIR/updater-script
echo 'run_program("/sbin/busybox", "mount", "/system");' >> $UPDATER_DIR/updater-script
echo 'endif;' >> $UPDATER_DIR/updater-script

unzip -q -o $ANDROID_BUILD_TOP/vendor/plain/tools/aroma/aroma.zip -d $ZIP_DIR
cat $ANDROID_BUILD_TOP/$AROMA_VENDOR_SCRIPT >> $UPDATER_DIR/updater-script
if [ -e $ANDROID_BUILD_TOP/$6 ]
then
cat $ANDROID_BUILD_TOP/$6 >> $UPDATER_DIR/updater-script
else
rm -rf $ZIP_DIR
continue
fi
cd $UPDATER_DIR
cp $ANDROID_BUILD_TOP/$AROMA_VENDOR_CONFIG $UPDATER_DIR/aroma-config
if [ -e $ANDROID_BUILD_TOP/$5 ]
then
awk '/#@AROMA_DEVICE_CONFIG@/{system("cat '$ANDROID_BUILD_TOP/$5'");next}1' $UPDATER_DIR/aroma-config > $UPDATER_DIR/temp
rm $UPDATER_DIR/aroma-config
mv $UPDATER_DIR/temp $UPDATER_DIR/aroma-config
mkdir -p $ZIP_DIR/aroma_device
cp -r $ANDROID_BUILD_TOP/$7/* $ZIP_DIR/aroma_device/
else
rm -rf $ZIP_DIR
continue
fi
sed -i -e "s|@AROMA_DEVICE@|$AROMA_DEVICE|" $UPDATER_DIR/aroma-config
sed -i -e "s|@DATE@|$AROMADATE|" $UPDATER_DIR/aroma-config

echo 'unmount("/system");' >> $UPDATER_DIR/updater-script
echo 'ui_print(" ");' >> $UPDATER_DIR/updater-script
echo 'ui_print("Done!");' >> $UPDATER_DIR/updater-script

cd $ZIP_DIR
zip -qr ../$AROMA_ZIP_OUT_FILE.zip ./
cd $OUT
rm -rf $ZIP_DIR

java -jar ${ANDROID_HOST_OUT}/framework/signapk.jar ${SOURCE}/build/target/product/security/testkey.x509.pem ${SOURCE}/build/target/product/security/testkey.pk8 $AROMA_ZIP_OUT_FILE.zip $AROMA_ZIP_OUT_FILE-signed.zip
rm ./$AROMA_ZIP_OUT_FILE.zip
md5sum $AROMA_ZIP_OUT_FILE-signed.zip
mkdir -p $OUT/system/addon.d
cp $AROMA_ZIP_OUT_FILE-signed.zip $OUT/system/addon.d/UPDATE-aromainstaller.zip
cd $SOURCE
