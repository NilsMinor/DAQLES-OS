FPGA_HW_DIR=/opt/fpga_hw/
BUILD_DIR=/opt/build/
echo "Copy fpga files to build folder"

pushd $FPGA_HW_DIR

cp -v *.bit $BUILD_DIR
cp -v *.hdf $BUILD_DIR

popd 