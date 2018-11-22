# Makefile in order to controll my scripts
# Based on Tigralt's zynq-boot makefile >https://github.com/Tigralt/zynq-boot/blob/master/Makefile<

# Directory definitions

DAQLES_DEV=~/daqles-dev

SD_DIR=/media/psf/DAQLES
SCRIPT_DIR=../daqles-scripts
UBOOT_DIR=../u-boot-xlnx
LINUX_DIR=../linux
CONFIG_DIR=../daqles-config
TARGET_DIR=../build
FPGA_HW_DIR=../fpga_hw
ARCHIVE_DIR=../archive
DTX_DIR=../device-tree-xlnx
DT_FILE=$(TARGET_DIR)/devicetree/system-top.dts
DTS_DAQLES=../daqles-dts


# File definitions
HDF_NAME=system_top
DTS_NAME=system-top

# linux
NUM_JOBS=7
CROSS_COMPILE=arm-linux-gnueabi-
ZYNQ_TYPE=zynq
IMG_NAME=uImage
LINUX_CONFIG=xilinx_zynq_defconfig

#SD card

MOUNT?=sdb
MOUNTED=`ls /dev | grep -c $(MOUNT)`

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
# check if xsdk is installed (required to build devicetree)
ifeq (, $(shell which xsdk))
        $(error "Missing xsdk, please install it.")
endif


prepare:
	@echo "Copy hdf design to build folder"
	@[ -d "$(TARGET_DIR)" ] || mkdir -v $(TARGET_DIR)
	@cp -v $(FPGA_HW_DIR)/$(HDF_NAME).hdf $(TARGET_DIR)
	@cp -v $(CONFIG_DIR)/uEnv.txt $(TARGET_DIR)
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


hdf-to-dts: prepare
	@echo "Create devicetree from file $(HDF_NAME).hdf"
	@[ -f "$(TARGET_DIR)/$(HDF_NAME).hdf" ] || (echo "No $(HDF_NAME).hdf found in $(TARGET_DIR)" && exit 1)
	@if [ ! -d "$(TARGET_DIR)/dts_build/" ]; then mkdir -v $(TARGET_DIR)/dts_build/; fi
	@cp $(TARGET_DIR)/$(HDF_NAME).hdf $(TARGET_DIR)/dts_build/
	@echo "hsi open_hw_design $(TARGET_DIR)/dts_build/$(HDF_NAME).hdf" > $(TARGET_DIR)/dts_build/create_dt.tcl
	@echo "hsi set_repo_path $(DTX_DIR)" >> $(TARGET_DIR)/dts_build/create_dt.tcl
	@echo "hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0" >> $(TARGET_DIR)/dts_build/create_dt.tcl
	@echo "hsi generate_target -dir $(TARGET_DIR)/devicetree">> $(TARGET_DIR)/dts_build/create_dt.tcl
	@xsdk -batch -source $(TARGET_DIR)/dts_build/create_dt.tcl
	@if [ -d "$(TARGET_DIR)/dts_build" ]; then rm -rf -v $(TARGET_DIR)/dts_build; fi
	@echo "Created dts files in folder $(TARGET_DIR)/devicetree, ready to  manipulate"

dtb-to-dts:
	#DT_FILE=$(TARGET_DIR)/devicetree.dtb
	@echo "Rebuild devicetree from file $(DT_FILE)"
	@[ -f "$(DT_FILE)" ] || (echo "Sorry, you need to pass a valid devicetree blob" && exit 1)
	@dtc -I dtb -O dts -o $(TARGET_DIR)/devicetree.dts $(DT_FILE)


dts-to-dtb:
	#DT_FILE=$(TARGET_DIR)/devicetree.dts
	@echo "Build devicetree from file $(DT_FILE)"
	@[ -f "$(DT_FILE)" ] || (echo "Sorry, you need to pass a valid devicetree " && exit 1)
	@dtc -I dts -O dtb -o $(TARGET_DIR)/devicetree.dtb $(DT_FILE)
	@echo "Build devicetree blob $(TARGET_DIR)/$(DTS_NAME).dts"

dts-linux:
	# build devicetree source from hardware description file -> [hdf-to-dts] 	
	# cp build/devicetree/* -> /build/dts_daqles by hand! modify it here
	# cp /build/dts_daqles -> linux/arch/arm/boot/dts/
	@echo "Build devicetree from file $(DTS_DAQLES)/"
	@if [ ! -d "$(DTS_DAQLES)/" ]; then (echo "Sorry, no $(DTS_DAQLES)/ path was found" && exit 1); fi
	cp -v $(DTS_DAQLES)/* $(LINUX_DIR)/arch/arm/boot/dts/
	make -C $(LINUX_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(DTS_NAME).dtb
	@[ -f "$(LINUX_DIR)/arch/arm/boot/dts/$(DTS_NAME).dtb" ] || (echo "No $(DTS_NAME).dtb found in $(LINUX_DIR)/arch/arm/boot/dts/" && exit 1)
	mv $(LINUX_DIR)/arch/arm/boot/dts/$(DTS_NAME).dtb $(TARGET_DIR)/devicetree.dtb

#clean:
#	@echo "Clean build folder"
#	@if [ -d "$(TARGET_DIR)" ]; then rm -rf -v $(TARGET_DIR); fi

copy-to-SD:
	@echo "Copy files to SD-Card"
	cp -v $(TARGET_DIR)/uImage $(SD_DIR)
	cp -v $(TARGET_DIR)/BOOT.BIN $(SD_DIR)
	cp -v $(TARGET_DIR)/uEnv.txt $(SD_DIR)
	cp -v $(TARGET_DIR)/devicetree.dtb $(SD_DIR)


format.sdcard:
	@[ $(MOUNTED) -gt 0 ] || (echo "SD card mount point '/dev/$(MOUNT)' not found. Is the sd card mounted?" && exit 1)
	@echo "Root authorization is required in order to format sd card."
	@echo "Verify that the sd card is not mounted, the format will fail otherwise!"
	@sudo dd if=/dev/zero of=/dev/$(MOUNT) bs=1024 count=1
	@echo "\nx\nh\n255\ns\n63\nr\nn\np\n1\n2048\n+200M\nn\np\n2\n\n\na\n1\nt\n1\nc\nt\n2\n83\nw\n" | sudo fdisk /dev/$(MOUNT)
	@sudo mkfs.vfat -F 32 -n BOOT /dev/$(MOUNT)1
	@sudo mkfs.ext4 -L root /dev/$(MOUNT)2
	@echo "SD card format successful! You can know copy files from '$(SDCARD_DIR)/' to SD card."



archive-old:
	@echo "Archive old build files"
	tar -cvf $(ARCHIVE_DIR)/build-$(timestamp).tar $(TARGET_DIR)
 
