#!/bin/bash
# Tool to build/rebuild devicetree

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
	cp $1 $BUILD_DIR
	echo "hsi open_hw_design `basename $1`" > $BUILD_DIR/create_dt.tcl	
	echo "hsi set_repo_path $DTX_DIR/" > $BUILD_DIR/create_dt.tcl  
 	echo "hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0" > $BUILD_DIR/create_dt.tcl  
	echo "hsi generate_target -dir `basename $1`"> $BUILD_DIR/create_dt.tcl    

	echo "build devicetree"	
	cd $BUILD_DIR
        xsdk -batch -source create_dt.tcl
popd

elif [[$1 = *.dtb]] 
then
	echo "convert dtb > dts"	
	dtc -I dtb -O dts -o $1 "$filename.dts" 

else
	echo "convert dts > dtb"
	dtc -I dts -O dtb -o "$filename.dtb" $1
fi


