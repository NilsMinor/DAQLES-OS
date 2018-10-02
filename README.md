
I started to work on those scripts while trying to build an SD Card Image for a custom Znyq-7000 FPGA Board from knowres gmbh.
The module I am using is the KRM-3Z7030. My target is to build a system using linux-adi branch 2017_R1 and u-boot branch xilinx-v2017.4 communicating to an high speed adc (AD9234).
However, while using to build all that modules I tried to automate my development by the scripts in the folder (zynq_scripts).

Some files are based on scripts from ADI (https://github.com/analogdevicesinc/wiki-scripts)

My development-flow and my scripts depend on the folder structure which looks like this:

Following tools needs to be installed and must be part of the $PATH in order to run them inside the scripts
- xsdk
- dtc
- make 
- hsi


Folder Structure:

```bash
/opt 
 ├──
 ├── build	  	(target build folder)
 ├── config       	(folder for defconfig for uboot and linux)
 ├── device-tree-xlnx   (Linux device tree generator for the Xilinx SDK (Vivado > 2014.1))
 ├── fpga_hw	  	(folder for fpga files like .bit and .hdf)
 ├── linux-adi    	(linux kernel directory) 
 ├── rootfs	  	(foder containing the root filesystem)
 ├── temp	  	(irrelevant old stuff)
 ├── u-boot-xlnx  	(u-boot directory)
 ├── Xilinx	  	(directory of xilinx tools like vivado and sdk (hsi))
 ├── zynq_scripts 	(scripts to build everything)	
```

#TODO Some descriptions of the folders and their conent
