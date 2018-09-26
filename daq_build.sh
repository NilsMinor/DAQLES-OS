#!/bin/bash
echo Build system
INSTRUCTION="$1"

SCRIPTS=/opt/scripts
BUILD=/opt/build/
FPGA=/opt/fpga_hw/
CONFIG=/opt/config

# Scripts in script folder:
# 	copy_files_to_SD_card.sh		: Copy all files from build dir to SD Card
#	copy_fpga_hw_to_build.sh		: Copy hw files from fpga_hw to build dir
#	build_zynq_kernel_image.sh		: build linux kernel based on ????_defconfig
# 	build_uboot.sh				: build uboot based on ??? _defconfig
#	build_bin.sh				: build BOOT.bin based on *.hdf, u-boot.elf system_top.bit



# all :	- Copy fpga hw files to build
#	- Build u-boot-elf and copy to build
#       - Build BOOT.bin
#

if [ "$INSTRUCTION" == "all" ]; then
	echo "Build all"
	# Copy fpga hw files to build
	$SCRIPTS/copy_fpga_hw_to_build.sh 
	# Build u-boot-elf and copy to build
	$SCRIPTS/build_uboot.sh $CONFIG/uboot_defconfig
	# Build BOOT.bin
	pushd $BUILD
	$SCRIPTS/build_bin.sh *.hdf *.elf system_top.bit
	popd
elif [ "$INSTRUCTION" == "clean" ]; then
       	pushd $BUILD
	rm -r ../build/*
	popd
elif [ "$INSTRUCTION" == "boot_bin" ]; then
	echo "Build BOOT.bin"
	# Build BOOT.bin
        pushd $BUILD
        $SCRIPTS/build_bin.sh *.hdf *.elf system_top.bit
        popd
elif [ "$INSTRUCTION" == "uboot" ]; then
        echo "Build u-boot"
	# Build u-boot-elf and copy to build
        $SCRIPTS/build_uboot.sh $CONFIG/uboot_defconfig
elif [ "$INSTRUCTION" == "serial" ]; then
        rxvt -e screen /dev/ttyUSB0 115200
elif [ "$INSTRUCTION" == "loadSD" ]; then
 	# Load files to SD Card
	$SCRIPTS/copy_files_to_SD_card.sh
else
	echo "Instruction > $1 < not supported"
fi


