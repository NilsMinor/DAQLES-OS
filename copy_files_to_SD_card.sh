#!/bin/bash
# Copy all files to SD Card
# tar old files to archiv folder
# remove old files

BUILD_DIR=/opt/build/
SD_DIR="/media/psf/NO NAME/"
echo "copy files to SD Card"

# Go to build folder and copy files to SD Card
pushd $BUILD_DIR
ls -la
if [ -d "$SD_DIR" ]; then
#	cp -v uImage "$SD_DIR" 
	cp -v *.BIN "$SD_DIR"

# Archive files
pushd ..
tar -cvf "archiv/build-$(date).tar" build/ 
rm -r build/*
popd
else
	echo "SD Card not found at path $SD_DIR"
fi

popd