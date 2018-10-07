# Makefile in order to controll my scripts
# Based on Tigralt's zynq-boot makefile >https://github.com/Tigralt/zynq-boot/blob/master/Makefile<

# Directory definitions
UBOOT_DIR=/opt/u-boot-xlnx
LINUX_DIR=/opt/linux-adi
CONFIG_DIR=/opt/config
TARGET_DIR=/opt/build
FPGA_HW_DIR=/opt/fpga_hw
HDF_NAME=system_top


# check required commands
LINUX_CROSS_COMPILE=arm-linux-gnueabi-

# check if gcc is installed (required to build linux and uboot)
ifeq (, $(shell which $(LINUX_CROSS_COMPILE)gcc))
        $(error "Missing $(LINUX_CROSS_COMPILE)gcc, please install it.")
endif
# check if hsi is installed (required to work with .hdf file)
ifeq (, $(shell which hsi))
        $(error "Missing hsi, please install it.")
endif
# check if mkimage is installed (required by uboot and uImage)
ifeq (, $(shell which mkimage))
        $(error "Missing mkimage, please install it.")
endif
# check if dtc is installed (required to build devicetree)
ifeq (, $(shell which dtc))
        $(error "Missing dtc, please install it.")
endif



prepare:
	@echo "Copy hdf design to build folder"
	@[ -d "$(TARGET_DIR)" ] || mkdir -v $(TARGET_DIR)
	@cp -v $(FPGA_HW_DIR)/$(HDF_NAME).hdf $(TARGET_DIR)

u-boot:
	@echo "Build u-boot"


boot.bin:
	@[ -f "$(TARGET_DIR)/system-top.hdf" ] || (echo "No $(HDF_NAME).hdf found in $(TARGET_DIR)" && exit 1)



clean:
	@echo "Clean build folder"
	@if [ -d "$(TARGET_DIR)" ]; then rm -rf -v $(TARGET_DIR); fi
