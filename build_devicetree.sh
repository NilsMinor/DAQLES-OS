#!/bin/bash
# Tool to build/rebuild devicetree

INSTRUCTION="$1"

# find name of file
filename=$(basename -- "$1")
filename="${filename%.*}"

echo "$filename _ $extension "

if [[ $1 == *.dtb ]] 
then
	echo "convert dtb > dts"	
	dtc -I dtb -O dts -o "$filename.dts" $1 

else
	echo "convert dts > dtb"
	dtc -I dts -O dtb -o $1 "$filename.dts"
fi


