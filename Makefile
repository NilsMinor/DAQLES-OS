# Makefile in order to controll my scripts
# Based on Tigralt's zynq-boot makefile >https://github.com/Tigralt/zynq-boot/blob/master/Makefile<

# Directory definitions
SD_DIR=/media/psf/NO\ NAME/
SCRIPT_DIR=/opt/zynq_scripts
UBOOT_DIR=/opt/u-boot-xlnx
LINUX_DIR=/opt/linux-adi
CONFIG_DIR=/opt/config
TARGET_DIR=/opt/build
FPGA_HW_DIR=/opt/fpga_hw
ARCHIVE_DIR=/opt/archive

# File definitions
HDF_NAME=system_top

# linux
NUM_JOBS=7
CROSS_COMPILE=arm-linux-gnueabi-
ZYNQ_TYPE=zynq
IMG_NAME=uImage
LINUX_CONFIG=xilinx_zynq_defconfig


# common
timestamp := `/bin/date "+%Y-%m-%d-%H-%M-%S"`

# check required commands

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
	@echo "Build u-boot, use old u-boot.elf file"
	cp -v $(CONFIG_DIR)/u-boot.elf $(TARGET_DIR)/

boot.bin: prepare
	@[ -f "$(TARGET_DIR)/$(HDF_NAME).hdf" ] || (echo "No $(HDF_NAME).hdf found in $(TARGET_DIR)" && exit 1)
	@[ -f "$(TARGET_DIR)/u-boot.elf" ] || (echo "No u-boot.elf found in $(TARGET_DIR)" && exit 1)
	$(SCRIPT_DIR)/build_bin.sh $(TARGET_DIR)/$(HDF_NAME).hdf $(TARGET_DIR)/u-boot.elf

linux:
	@[ -d "$(LINUX_DIR)" ] || (echo "No linux directory found!" && exit 1)
	cp -v $(CONFIG_DIR)/$(LINUX_CONFIG) $(LINUX_DIR)/arch/arm/configs/
	make -C $(LINUX_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_CONFIG) 
	make -j$(NUM_JOBS) -C $(LINUX_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(IMG_NAME) UIMAGE_LOADADDR=0x8000
	cp -v $(LINUX_DIR)/arch/arm/boot/$(IMG_NAME) $(TARGET_DIR)/


devicetree-dts:
	 @echo "Build devicetree"

devicetree-dtb:


clean:
	@echo "Clean build folder"
	@if [ -d "$(TARGET_DIR)" ]; then rm -rf -v $(TARGET_DIR); fi

copy-to-SD:
	@echo "Copy files to SD-Card"
	cp -v $(TARGET_DIR)/uImage $(SD_DIR)
	cp -v $(TARGET_DIR)/BOOT.BIN $(SD_DIR)
	cp -v $(TARGET_DIR)/uEnv.txt $(SD_DIR)
	cp -v $(TARGET_DIR)/devicetree.dtb $(SD_DIR)

archive-old:
	@echo "Archive old build files"
	tar -cvf $(ARCHIVE_DIR)/build-$(timestamp).tar $(TARGET_DIR)
 
