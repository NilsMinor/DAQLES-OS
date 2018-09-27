#!/bin/bash
# Tool to build/rebuild devicetree

INSTRUCTION="$1"

# find name of file
filename=$(basename -- "$1")
filename="${filename%.*}"

if [[ $1 == *.dtb ]] 
then
	echo "convert dtb > dts"	
	dtc -I dtb -O dts -o $1 "$filename.dts" 

else
	echo "convert dts > dtb"
	dtc -I dts -O dtb -o "$filename.dtb" $1
fi


