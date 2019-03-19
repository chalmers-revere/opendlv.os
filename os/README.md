# opendlv.os

This repository contains scripts for automated installation of a computer
operating system capable of running the containerized OpenDLV framework.

    Warning!! The scripts will completely erase your entire harddrive (ALL YOUR 
    DATA WILL BE LOST). Do this only if you know exactely what you are doing. 
    Use on your own risk, we are not responsible for any lost data from running 
    these scripts!

## Automated install on a x86 PC

1. Create a Arch Linux bootable USB drive by following the instructions given 
   at: https://wiki.archlinux.org/index.php/USB_flash_installation_media
2. Boot the computer using the bootable USB
3. Download the automated scripts with:

   ```
     wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/x86/get.sh
     sh get.sh
   ```
4. Enable the setups that you want to enable on the machine, e.g.:

   ```
     cp setup-available/setup-chroot-01-rtkernel.sh .
     cp setup-available/setup-post-01-router.sh .
   ```
5. Configure the basic installation and the enabled setups. Check the network interface name with 'ip a' and the harddrive device name with 'lsblk'.

   ```
     vim install-conf.sh
     vim setup-post-01-router.sh
   ```
6. Run the automated installation with (REMEMBER: all your data will be lost. You have been warned!):

   ```
     chmod +x *.sh
     ./install.sh
   ```

## Automated install on a BeagleBone Black

1. Create a Arch Linux Arm bootable SD card by following the instructions given
   at https://archlinuxarm.org/platforms/armv7/ti/beaglebone-black
2. Boot the BeagleBone Black using the bootable SD card
3. Download the automated scripts with:

   ```
     wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/arm-bbb/get.sh
     sh get.sh
   ```
4. Enable the setups that you want to enable on the machine, e.g.:

   ```
     cp setup-available/setup-post-01-pru.sh .
   ```
5. Configure the basic installation and the enabled setups.

   ```
     vim install-conf.sh
     vim setup-post-01-pru.sh
   ```
6. Run the automated installation with (REMEMBER: all your data will be lost. You have been warned!):

   ```
     chmod +x *.sh
     ./install.sh
   ```
