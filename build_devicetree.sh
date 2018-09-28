#!/bin/bash
#
# Nils Minor 09/2018 project [ DAQLES ]
#
# Script to build or rebuild the devicetree depending on the committed file
#
# input files	: [1] *.dts or *.dtb or *.hdf
# output files	: [1] *.dts or *.dtb or *.hdf
#
# The script generates the following output
# input (*.dts) > output (*.dtb) build devicetree blob
# input (*.dtb) > output (*.dts) rebuild devicetree from blob
# input (*.hdf) > output (*.dts) build device tree from hardware
#


INSTRUCTION="$1"
BUILD_DIR=build_devicetree
TARGET_DIR=/opt/build
DTX_DIR=/opt/device-tree-xlnx

# find name of file
filename=$(basename -- "$1")
filename="${filename%.*}"

if [[ $1 == *.hdf ]]
then
pushd $TARGET_DIR

	echo "build create_dt.tcl"
	mkdir -p $BUILD_DIR
	cp "$filename.hdf" $BUILD_DIR/
	echo "hsi open_hw_design $filename.hdf" > $BUILD_DIR/create_dt.tcl
	echo "hsi set_repo_path $DTX_DIR/" >> $BUILD_DIR/create_dt.tcl
 	echo "hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0" >> $BUILD_DIR/create_dt.tcl  
	echo "hsi generate_target -dir $filename">> $BUILD_DIR/create_dt.tcl

	echo "build devicetree"
	cd $BUILD_DIR
        xsdk -batch -source create_dt.tcl
	mv $filename $TARGET_DIR/
	rm -r $TARGET_DIR/$BUILD_DIR
popd

elif [[ $1 = *.dtb ]] 
then
	echo "convert dtb > dts for file $1"
	dtc -I dtb -O dts -o $1 "$filename.dts" 

else
	echo "convert dts > dtb for file $1"
	dtc -I dts -O dtb -o "$filename.dtb" $1
fi


