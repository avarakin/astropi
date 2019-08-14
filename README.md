# Introduction

This project contains instructions and Makefile for setting up a Raspberry Pi as an Astrophotography computer.
Both 18.4 and 16.04 versions of Ubuntu Mate are supported.
Experimental Raspberry Pi 4 installation is also available.
The project originally started as a shell script, but then was migrated to makefile. Shell script is still available but not updated. 

# List of features:
1. Installs most commonly used Astrophotography software:
* INDI
* Kstars
* PHD2
* CCDCiel
* Skychart
* Astrometry with sextractor
2. Sets up Wireless Access Point. Default name is RPI and password is password but can be changed in the script. Once connected to WAP,  IP address of PI is 10.0.0.1
3. Sets up x11vnc to be started automatically
4. Configures screen to be 1920x1080 for headless operation
5. Configures USB to provide up to 1A of current to connected devices
6. Configures the onboard serial port for controlling an external device

# Installing on RPI 4
This method is based on installing Ubuntu Server and then replacing the firmware by Raspbian firmware and is based on the following instructions:

https://jamesachambers.com/raspberry-pi-ubuntu-server-18-04-2-installation-guide/

1. Get image from:

http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.2-preinstalled-server-armhf+raspi3.img.xz

2. Unpack and burn into SD Card:

```
xz -d ubuntu-18.04.2-preinstalled-server-armhf+raspi3.img.xz
sudo ddrescue -D --force ubuntu-18.04.2-preinstalled-server-armhf+raspi3.img /dev/sdx
```
Insert/mount the micro SD card in your computer and navigate to the “boot” partition. Delete everything in the existing folder so it is completely empty.

3. Download firmware from:

https://github.com/raspberrypi/firmware/archive/master.zip

The latest firmware is everything inside master.zip “boot” folder (including subfolders). We want to extract everything from “boot” (including subfolders) to our micro SD’s “boot” partition that we just emptied in the previous step. Don’t forget to get the “overlays” folder as that contains overlays necessary to boot correctly.


4. Create/Update config.txt and cmdline.txt

Navigate to the micro SD /boot/ partition. Create a blank cmdline.txt file with the following line:

```
dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0
```

Next we are going to create config.txt with the following content:

```
## Enable audio (loads snd_bcm2835)
dtparam=audio=on
[pi4]
[all]
hdmi_force_hotplug=1
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=82
disable_overscan=1
```

5. Final steps

Connect Ethernet cable, put in the card into RPI and boot.
It may take up to 10 minutes to boot, especially if mouse is not connected, so be patient.
Once Raspberry is running, connect to it using ssh, with user/password : ubuntu/ubuntu
 and then run the following commands

```
sudo apt remove flash-kernel initramfs-tools
sudo apt-get install git make
git clone https://github.com/avarakin/astropi.git
cd astropi
sudo make pi4
```
This will take an hour or so. It may ask some questions, so monitor the process.


## Steps for setting up RPi 3:
1. Download and install Ubuntu Mate 16.04 or 18.04 from:
https://ubuntu-mate.org/raspberry-pi/
Follow instructions up to SSH section. The script contains commands for enabling ssh too. 

Looks like image for 16.04 is no longer accessible direclty on the Mate site. Here is a link which is still available:
https://ubuntu-mate.org/raspberry-pi/ubuntu-mate-16.04.2-desktop-armhf-raspberry-pi.img.xz

Stock 16.04.2 does not boot on RPI 3 B+.
The following steps need to be made on working RPI 3 B after installation is complete:
```
sudo rpi-update
sudo wget https://github.com/khadas/android_hardware_amlogic_wifi/raw/b6709758755568e4a0ff6e80993be0fc64c77fb9/bcm_ampak/config/6255/nvram.txt -O /lib/firmware/brcm/brcmfmac43455-sdio.txt
```
and then the card can be moved to RPI 3 B+.

2. Once Raspberry is running, open terminal and run the following commands:
```
sudo apt-get install git make
git clone https://github.com/avarakin/astropi.git
cd astropi
sudo make pi3
```


## Notes for 18.04
Couple of things required changes in the script to support 18.04:
1. For some reason the ssh keys were not present after the install so the script has the steps to create them.
2. Ubuntu 18.04 comes with its own DNS server which conflicts with dnsmasq. The script has commands for disabling the DNS server and changing resolv.conf to be compatible with dnsmasq

## Notes for RPI 4
1. Server version of Ubuntu has LXD and cloud software  which is not needed so it is removed
2. Random number generator is taking a lot of time during the boot so "haveged" random generator is installed as part of the installer script
3. Wifi and logitech wireless mouse/keyboard are not working. Need to install raspbian drivers



