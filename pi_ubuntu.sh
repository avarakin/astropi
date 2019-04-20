sudo apt-get update
sudo apt-get upgrade

#install general utilities
sudo apt-get -y install mc git vim ssh x11vnc zsh synaptic fonts-roboto chromium-browser terminator

#enable ssh
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh


#There steps were needed on 18.04 to get sshd working. Uncomment and run in case if you face same issue
#sudo rm /etc/ssh/ssh*key
#sudo dpkg-reconfigure openssh-server
#sudo systemctl restart ssh
#sudo systemctl status ssh


#install indi and kstars
sudo apt-add-repository ppa:mutlaqja/ppa
sudo apt-get update
sudo apt-get -y install indi-full kstars-bleeding
sudo apt-get -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
sudo echo "deb http://www.ap-i.net/apt unstable main" > /tmp/1.tmp && sudo cp /tmp/1.tmp /etc/apt/sources.list.d/skychart.list
sudo apt-get update && sudo apt-get -y install ccdciel skychart


#install phd2
sudo add-apt-repository ppa:pch/phd2 && sudo apt-get update && sudo apt-get -y install phd2 phdlogview


#create a sample INDI startup shell script
echo "indiserver -v indi_lx200_OnStep indi_sbig_ccd indi_asi_ccd indi_sx_wheel" >> ~/indi.sh
chmod 777 ~/indi.sh


#Setting up Wireless Access Point


#The following commands were needed to get dnsmasq running on 18.04:
#sudo systemctl stop systemd-resolved
#sudo systemctl disable systemd-resolved
#sudo rm /etc/resolv.conf
#sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
#sudo chattr -e /etc/resolv.conf
#sudo chattr +i /etc/resolv.conf


sudo apt-get -y install hostapd dnsmasq make


cd ~ && git clone https://github.com/oblique/create_ap && cd create_ap && sudo make install

#configure access point id and password
sudo sed -i.bak 's/SSID=MyAccessPoint/SSID=RPI/'  /etc/create_ap.conf 
sudo sed -i.bak 's/PASSPHRASE=12345678/PASSPHRASE=password/'  /etc/create_ap.conf 

# For 16.04 this step needs to be done manually:
# 1. run  ifconfig and note down the name of ethernet interface. It will be like et433hkjh5345345
# 2. in /etc/create_ap.conf  replace eth0 by the name from the step 1

sudo systemctl enable create_ap
sudo systemctl start create_ap
sudo systemctl status create_ap


#configure x11vnc 
cat > /tmp/1.tmp  << EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target
[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
[Install]
WantedBy=multi-user.target
EOF

sudo cp /tmp/1.tmp  /lib/systemd/system/x11vnc.service

sudo x11vnc -storepasswd /etc/x11vnc.pass
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service

#configure display to be 1920x1080 and high current USB
sudo sed -i.bak 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/; s/#hdmi_ignore_edid=0xa5000080/hdmi_ignore_edid=0xa5000080/; s/#hdmi_group=1/hdmi_group=1/; s/##     16       1080p 60Hz/     16       1080p 60Hz/; s/#overscan_left=0/overscan_left=0/; s/#overscan_right=0/overscan_right=0/; s/#overscan_top=0/overscan_top=0/; s/#overscan_bottom=0/overscan_bottom=0/; s/#disable_overscan=1/disable_overscan=1/; s/#max_usb_current=0/max_usb_current=1/;'  /boot/config.txt

#add user pi to dialout group so it can access serial ports
sudo gpasswd --add pi dialout

#Optional steps to configure the onboard serial port for controlling an external device
#configure pins 8 and 10 to become serial0. This will disable Bluetooth
sudo sed -i.bak 's/console=serial0,115200//'  /boot/cmdline.txt
sudo sh -c "echo dtoverlay=pi3-disable-bt >> /boot/config.txt"
sudo systemctl stop hciuart
sudo systemctl disable hciuart

