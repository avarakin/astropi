This project contains instructions and shell script for setting up a Raspberry Pi as an Astrophotography computer.

## List of features:
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

## Steps for setting up:
1. Download and install Ubuntu Mate 16.04 from:
https://ubuntu-mate.org/raspberry-pi/
Follow instructions up to SSH section. The script contains commands for enabling ssh too. 
2. Once Raspberry is running, open terminal and run the following commands:
```
sudo apt-get install git
git clone https://github.com/avarakin/astropi.git
cd astropi
chmod 777 pi_ubuntu.sh
cat pi_ubuntu.sh
```

3. Once this is done, you can either run the whole script or copy - paste the commands to terminal one by one. At this point the script is still in testing stage, so it is recommended to run it line by line. When you run it line by line, make sure that the whole command is copied to buffer - some commands span over multiple lines or are a long single line.


## Instructions for 18.04

Download on this page:

https://ubuntu-mate.org/download/

https://ubuntu-mate.org/raspberry-pi/ubuntu-mate-18.04.2-beta1-desktop-armhf+raspi-ext4.img.xz

sudo apt-get install gddrescue xz-utils
unxz ubuntu-mate-18.04.2-beta1-desktop-armhf+raspi-ext4.img.xz
sudo ddrescue -D --force ubuntu-mate-18.04.2-beta1-desktop-armhf+raspi-ext4.img /dev/sdx
