#.PHONY: update utils vscode

pi4: update mate-desktop utils indi_kstars ccdciel_skychart phd vnc groups-pi4

#display_usb serial 

pi3: update ssh utils indi_kstars ccdciel_skychart phd sample_startup wap vnc display_usb serial groups

update:
	apt-get update && apt-get -y upgrade 
	apt-get -y purge unattended-upgrades
	
update_firmware:
	git clone --depth 1 https://github.com/raspberrypi/firmware
	cp -r firmware/boot/* /boot/firmware/
	cp -r firmware/modules/* /lib/modules

#install general utilities
utils :
	apt-get -y install mc git vim ssh x11vnc zsh synaptic fonts-roboto chromium-browser terminator

#enable ssh
ssh :
	systemctl enable ssh
	systemctl start ssh
	systemctl status ssh


mate-desktop :
	apt-get -y install mate-desktop-environment lightdm
	apt-get -y remove lxd lxd-client
	apt-get purge cloud-init
	rm -rf /etc/cloud/
	rm -rf /var/lib/cloud/
	apt-get -y install haveged
	systemctl enable haveged


#These steps were needed on 18.04 to get sshd working. Uncomment and run in case if you face same issue
ssh-18.04 :
	rm /etc/ssh/ssh*key
	dpkg-reconfigure openssh-server
	systemctl restart ssh
	systemctl status ssh


#install indi and kstars
indi_kstars :
	apt-add-repository -y ppa:mutlaqja/ppa
	apt-get update
	apt-get -y install indi-full kstars-bleeding
	apt-get -y install astrometry.net astrometry-data-tycho2 astrometry-data-2mass-08-19 astrometry-data-2mass-08-19 astrometry-data-2mass-07 astrometry-data-2mass-06 sextractor

#install ccdciel and skychart
ccdciel_skychart :
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2
	echo "deb http://www.ap-i.net/apt unstable main" > /tmp/1.tmp && cp /tmp/1.tmp /etc/apt/sources.list.d/skychart.list
	apt-get update && apt-get -y install ccdciel skychart


#install phd2
phd :
	add-apt-repository -y  ppa:pch/phd2 && apt-get update && apt-get -y install phd2 phdlogview


#create a sample INDI startup shell script
sample_startup :
	echo "indiserver -v indi_lx200_OnStep indi_sbig_ccd indi_asi_ccd indi_sx_wheel" >> ~/indi.sh
	chmod 777 ~/indi.sh


#Setting up Wireless Access Point

#The following commands were needed to get dnsmasq running on 18.04:
wap_18.04 :
	systemctl stop systemd-resolved
	systemctl disable systemd-resolved
	rm /etc/resolv.conf
	sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
	chattr -e /etc/resolv.conf
	chattr +i /etc/resolv.conf


wap :
	apt-get -y install hostapd dnsmasq make
	cd ~ && git clone https://github.com/oblique/create_ap && cd create_ap && make install
	#configure access point id and password
	sed -i.bak 's/SSID=MyAccessPoint/SSID=RPI/'  /etc/create_ap.conf 
	sed -i.bak 's/PASSPHRASE=12345678/PASSPHRASE=password/'  /etc/create_ap.conf 
	systemctl enable create_ap
	systemctl start create_ap
	systemctl status create_ap
	$(eval INTERFACE=$(shell sh -c ifconfig | head -1 | awk '{print $$1}'))
	@echo Replacing network interface by: $(INTERFACE)
	sed -i.bak 's/eth0/$(INTERFACE)/'   /etc/create_ap.conf


#configure x11vnc 
VNC=/lib/systemd/system/x11vnc.service
vnc :
	echo [Unit] > $(VNC)
	echo Description=Start x11vnc at startup. >> $(VNC)
	echo After=multi-user.target >> $(VNC)
	echo [Service]>> $(VNC)
	echo Type=simple>> $(VNC)
	echo ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared>> $(VNC)
	echo [Install]>> $(VNC)
	echo WantedBy=multi-user.target>> $(VNC)
	x11vnc -storepasswd /etc/x11vnc.pass
	systemctl enable x11vnc.service
	systemctl start x11vnc.service

#configure display to be 1920x1080 and high current USB
display_usb :
	sed -i.bak 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/; s/#hdmi_ignore_edid=0xa5000080/hdmi_ignore_edid=0xa5000080/; s/#hdmi_group=1/hdmi_group=1/; s/##     16       1080p 60Hz/     16       1080p 60Hz/; s/#overscan_left=0/overscan_left=0/; s/#overscan_right=0/overscan_right=0/; s/#overscan_top=0/overscan_top=0/; s/#overscan_bottom=0/overscan_bottom=0/; s/#disable_overscan=1/disable_overscan=1/; s/#max_usb_current=0/max_usb_current=1/;'  /boot/config.txt

#add user pi to dialout group so it can access serial ports
groups :
	gpasswd --add pi dialout

groups-pi4 :
	gpasswd --add ubuntu dialout



#Optional steps to configure the onboard serial port for controlling an external device
#configure pins 8 and 10 to become serial0. This will disable Bluetooth
serial :
	sed -i.bak 's/console=serial0,115200//'  /boot/cmdline.txt
	sh -c "echo dtoverlay=pi3-disable-bt >> /boot/config.txt"
	systemctl stop hciuart
	systemctl disable hciuart
