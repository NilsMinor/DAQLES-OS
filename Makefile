# Makefile in order to controll my scripts
# Based on Tigralt's zynq-boot makefile >https://github.com/Tigralt/zynq-boot/blob/master/Makefile<

# Directory definitions
UBOOT_DIR=/opt/u-boot-xlnx
LINUX_DIR=/opt/linux-adi
CONFIG_DIR=/opt/config
TARGET_DIR=/opt/build


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




u-boot:
	@echo "Make u-boot"
