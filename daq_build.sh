#!/bin/bash
# Main script to control sub-scripts

echo Build system
INSTRUCTION="$1"
PARAMETER="$2"

# folder structure
SCRIPTS_DIR=/opt/zynq_scripts
BUILD_DIR=/opt/build
FPGA_DIR=/opt/fpga_hw
CONFIG_DIR=/opt/config

# Scripts in script folder:
# 	copy_files_to_SD_card.sh		: Copy all files from build dir to SD Card
#	copy_fpga_hw_to_build.sh		: Copy hw files from fpga_hw to build dir
#	build_zynq_kernel_image.sh		: build linux kernel based on ????_defconfig
# 	build_uboot.sh				: build uboot based on ??? _defconfig
#	build_bin.sh				: build BOOT.bin based on *.hdf, u-boot.elf system_top.bit
#	build_devicetree.sh			: build dts or dtb, depends on input file (.hdf/ .dts/ .dtb)

# Commands
#
# all		:	- Copy fpga hw files to build
#			- Build u-boot-elf and copy to build
#       		- Build BOOT.bin
# serial	:	- open rxvt with screen on USB0
# clean		:	- clean build folder
# uboot		: 	- build u-boot with config/uboot_defconfig
# bootbin	:	- build boot.bin from .hdf and uboot.elf from build folder
# loadSD	:	- load files from build folder to SD-Card (change SD-card name inside script)
# kernel	: 	- build linux kernel (linux-adi) with config/linux_config
# dtb		:	- build dts from hdf (parameter = .hdf)
#			- build dts from dtb (parameter = .dtb)
#			- rebuild dtb from dts (parameter = .dtb)



# check files and directories
if [ ! -d "$BUILD_DIR" ];then
	echo "build directory is not  defined"
	exit 1;
fi
if [ ! -d "$SCRIPTS_DIR" ];then
        echo "script directory is not  defined"
        exit 1;
fi
if [ ! -d "$FPGA_DIR" ];then
        echo "fpga directory is not  defined"
        exit 1;
fi
if [ ! -d "$CONFIG_DIR" ];then
        echo "config directory is not  defined"
        exit 1;
fi


if [ "$INSTRUCTION" == "all" ]; then

	echo "Build all"
	# Copy fpga hw files to build
	$SCRIPTS_DIR/copy_fpga_hw_to_build.sh 
	# Build u-boot-elf and copy to build
	$SCRIPTS_DIR/build_uboot.sh $CONFIG_DIR/uboot_defconfig
	# Build BOOT.bin
	pushd $BUILD_DIR/
	$SCRIPTS_DIR/build_bin.sh *.hdf *.elf system_top.bit
	popd

elif [ "$INSTRUCTION" == "clean" ]; then
	pushd $BUILD_DIR
	cd ..
	rm -r build/*
	popd
elif [ "$INSTRUCTION" == "bootbin" ]; then

	# Build BOOT.bin
	echo "Build BOOT.bin"
        pushd $BUILD_DIR/
        $SCRIPTS_DIR/build_bin.sh *.hdf *.elf system_top.bit
        popd

elif [ "$INSTRUCTION" == "uboot" ]; then

	# Build u-boot-elf and copy to build
        echo "Build u-boot"
        $SCRIPTS_DIR/build_uboot.sh $CONFIG_DIR/uboot_defconfig

elif [ "$INSTRUCTION" == "serial" ]; then

        rxvt -e screen /dev/ttyUSB0 115200

elif [ "$INSTRUCTION" == "loadSD" ]; then

 	# Load files to SD Card
	$SCRIPTS_DIR/copy_files_to_SD_card.sh

elif [ "$INSTRUCTION" == "kernel" ]; then

        echo "Build linux-adi"
	$SCRIPTS_DIR/build_zynq_kernel_image.sh 

elif [ "$INSTRUCTION" == "dtb" ]; then

        echo "Build devicetree from hdf"
	# copy .hdf to  build folder
	$SCRIPTS_DIR/copy_fpga_hw_to_build.sh
	# build dts from hdf
        $SCRIPTS_DIR/build_devicetree.sh $BUILD_DIR/system_top.hdf
	if [ ! -d "$BUILD_DIR/system_top/" ];then
          echo "no system_top folder containing .dts files found"
          exit 1;
	else
	# check if there is an dts file, then build dtb from dts
	  if [ ! -f "$BUILD_DIR/system_top/system.dts" ];then
            echo "no system.dts file found"
            exit 1;
          else
	    echo "found system.dts in system_top folder"
	    $SCRIPTS_DIR/build_devicetree.sh $BUILD_DIR/system_top/system-top.dts
	    # copy dtb to build folder
	    cp -v system-top.dtb $BUILD_DIR
	   #rename file to devicetree.dtb
	   mv $BUILD_DIR/system-top.dtb $BUILD_DIR/devicetree.dtb
	 fi
	fi
else

	echo "Instruction > $1 < not supported"

fi


