#!/bin/bash
#
# Nils Minor 09/2018 project [ DAQLES ]
#
# Script to copy necessar files from build folder to SD Card,
# tar old files to and move them to archiv folder with timestamp
# also removes cleans build folder
#
# input files	:
# output files	:
#


BUILD_DIR=/opt/build
CONFIG_DIR=/opt/config
SD_DIR="/media/psf/NO NAME/"

echo "copy files to SD Card"

# Copy uEnv config to build folder
cp $CONFIG_DIR/uEnv.txt $BUILD_DIR/

# Go to build folder and copy files to SD Card
pushd $BUILD_DIR/
ls -la
if [ -d "$SD_DIR" ]; then
#	cp -v uImage "$SD_DIR" 
	cp -v *.BIN "$SD_DIR"
	cp -v uEnv.txt "$SD_DIR"
	cp -v *.dtb "$SD_DIR" 
	sync
# Archive files
pushd ..
	tar -cvf "archiv/build-$(date).tar" build/ 
	rm -r build/*
popd
else
	echo "SD Card not found at path $SD_DIR"
fi

popd
