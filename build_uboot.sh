#!/bin/bash
# Build u-boot from u-boot-xlnx and copy .elf file to build folder

USER_DEFCONFIG=$1
UBOOT_DIR=/opt/u-boot-xlnx

# copy custom defconfig to configs dir
cp $USER_DEFCONFIG $UBOOT_DIR/configs/
echo "Use defconfig $USER_DEFCONFIG"

# Go to u-boot dir and show git status
pushd $UBOOT_DIR
echo "Build uBoot, GIT tag :" 
#git status

# setup cross compiler
export CROSS_COMPILE=arm-linux-gnueabi-
export ARCH=arm

# make config
make uboot_defconfig
#make zynq_zc706_defconfig

#build uboot
make

#copy image to build folder
cp u-boot ../build/u-boot.elf

popd
