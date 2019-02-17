This project contains instructions and shell script for setting up a Raspberry Pi as an Astrophotography computer.

List of features:
1. Installs most commonly used Astrophotography software:
INDI
Kstars
PHD2
CCDCiel
2. Sets up Wireless Access Point. Default name is RPI and password in password but can be changed in the script. Once connected to WAP,  IP address of device is 10.0.0.1
3. Sets up x11vnc to be started automatically
4. Configures screen to be 1920x1080 for headless operation
5. Configures USB to provide up to 1A of current to connected devices

Steps for setting up:
1. Download and install Ubuntu Mate 16.04 from:
https://ubuntu-mate.org/raspberry-pi/
Follow instructions up to SSH section. The script contains commands for enabling ssh too. 
2. Once Raspberry is running, open command line and run the following commands
sudo apt-get install git
git clone https://github.com/avarakin/astropi.git
cd astropi
cat pi_ubuntu.sh
chmod 777 pi_ubuntu.sh

Once this is done, you can either run the whole script or copy - paste the commands to terminal one by one

