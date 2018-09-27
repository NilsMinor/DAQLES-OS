#!/bin/bash
set -e

DTFILE="$1"

BUILD_DIR=/opt/build
LINUX_DIR=/opt/linux-adi
CONFIG_DIR=/opt/config
NUM_JOBS=7

HOST=${HOST:-x86_64}

# Copy custom defconfig to linux-adi/confgis/ 
if [ -e  "$CONFIG_DIR/linux_defconfig" ] ; then
	cp $CONFIG_DIR/linux_defconfig 	$LINUX_DIR/arch/arm/configs/
else
	echo "No linux_defconifg file found"
fi

#DEFCONFIG=zynq_xcomm_adv7511_defconfig
#DEFCONFIG=xilinx_zynq_defconfig
CROSS_COMPILE=arm-linux-gnueabi-
DEFCONFIG=linux_defconfig
GCC_ARCH=arm-linux-gnueabi
ZYNQ_TYPE=zynq
IMG_NAME="uImage"
ARCH=arm
DTDEFAULT=zynq-zc702-adv7511-ad9361-fmcomms2-3.dtb

export ARCH
export CROSS_COMPILE

pushd "$LINUX_DIR/"

make $DEFCONFIG

make -j$NUM_JOBS $IMG_NAME UIMAGE_LOADADDR=0x8000

if [ -z "$DTFILE" ] ; then
	echo
	echo "No DTFILE file specified ; using default '$DTDEFAULT'"
	DTFILE=$DTDEFAULT
fi

echo "Build Devicetree"
make $DTFILE

popd 1> /dev/null

cp -f $LINUX_DIR/arch/$ARCH/boot/$IMG_NAME $BUILD_DIR/
cp -f $LINUX_DIR/arch/$ARCH/boot/dts/$DTFILE $BUILD_DIR/


echo "Exported files: $IMG_NAME, $DTFILE"

