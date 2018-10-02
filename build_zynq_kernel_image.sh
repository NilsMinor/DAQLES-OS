#!/bin/bash
#
# Nils Minor 09/2018 project [ DAQLES ]
#
# Script to build the linux kernel (linux-adi) depending on custom config or
# the default caonfig from config/linux_defconfig
#
# input files	:
# output files	:
#
#
#

set -e

CUSTOM_DEFCONFIG=$1

BUILD_DIR=/opt/build
LINUX_DIR=/opt/linux-adi
CONFIG_DIR=/opt/config
NUM_JOBS=7
DEFCONFIG=linux_defconfig 


HOST=${HOST:-x86_64}

if [ -z  "$CUSTOM_DEFCONFIG" ] ; then
	echo "Use default defconfig config/linux_defconfig"
	cp -v $CONFIG_DIR/linux_defconfig $LINUX_DIR/arch/arm/configs/
else
  # TODO fix custom defconfig error, use now xilinx_zynq ...
  DEFCONFIG=xilinx_zynq_defconfig
  # Copy custom defconfig to linux-adi/confgis/
	echo "copy $DEFCONFIG to linux-dir" 
  if [ -e  "$CONFIG_DIR/$DEFCONFIG" ] ; then
	cp -v $CONFIG_DIR/"$DEFCONFIG" $LINUX_DIR/arch/arm/configs/
  else
	echo "No linux_defconifg file found"
  fi
fi

CROSS_COMPILE=arm-linux-gnueabi-
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
popd 1> /dev/null

echo "Building $IMG_NAME done"


#if [ -z "$DTFILE" ] ; then
#	echo
#	echo "No DTFILE file specified ; using default '$DTDEFAULT'"
#	DTFILE=$DTDEFAULT
#fi

# copy uImage to build/
cp -f $LINUX_DIR/arch/$ARCH/boot/$IMG_NAME $BUILD_DIR/


# For building dtb
#cp -f $LINUX_DIR/arch/$ARCH/boot/dts/$DTFILE $BUILD_DIR/



