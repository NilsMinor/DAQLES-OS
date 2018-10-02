#!/bin/bash
#
# Nils Minor 09/2018 project [ DAQLES ]
#
# Script to remove previous built files from build folder
#

TARGET_DIR=/opt/build

pushd $TARGET_DIR
	echo "clean build folder"
        rm -r -v system_top/
        rm -r -v build_boot_bin/
	rm -r -v output_boot_bin
  	rm -v uImage
        rm -v *.hdf
	rm -v *.dtb
	rm -v BOOT.BIN
#	rm -v *.elf
popd



