Elrond real-time node performance and health monitoring with Netdata
powered by DisruptiveDigital 2020-2021
special thanks to @FRANKF1957 and all the helpful friends in the Elrond - Netdata Users telegram group
please join Elrond - Netdata Users for more info - https://t.me/Elrond_Netdata_Users

This script installs Netdata real-time, performance and health monitoring solution and automates all the necessary configurations to properly monitor your Elrond nodes.

> Before starting, you should set up the telegram bot
- in telegram access @BotFather 
- enter this command: /newbot
    - choose a name for your bot
    - choose a username for your bot
    - save your access token - you will need this later
- create a new group where you want to receive Netdata alarms/notifications
    - invite your bot created in the previous step
    - invite a second bot @myidbot to this group
    - enter this command: /getgroupid
    - save your group ID - you will need this later


> Git clone one-line script installer

Note: Don't run the script as root.

> Make sure you have git installed, if not, run the following commands:
sudo apt update
sudo apt install git

> If the script already exists please delete the folder first:
rm -rf dd-netdata-install-erdapi

> Then git clone:
cd ~ && git clone https://github.com/disruptivedigital/dd-netdata-install-erdapi.git && cd dd-netdata-install-erdapi && bash netdata-install-config.sh


Node parameters in netdata.cloud:
elrond.round = Consensus round
elrond.vblocks = Validator blocks signed/accepted
elrond.lblocks = Leader blocks proposed/accepted
elrond.rating = Current node (tempRating) rating
elrond.epoch = Current epoch
elrond.peers = Connected peers
elrond.vn = Connected validators / total nodes
elrond.lsf = Leader success/failure
elrond.vsf = Validator success/failure
elrond.is = Validator ignored signatures
elrond.tlsf = Total leader success/failure
elrond.tvsf = Total validator success/failure
elrond.tis = Total ignored signatures


The alarms are configured as follows:

> Elrond node is not maintaining synchronization
- WARNING if out of sync more than 02:20 (hysteresis) consensus rounds
- CRITICAL if out of sync more than 20:200 (hysteresis) consensus rounds 

> Elrond node rating dropping
- WARNING if node rating is dropping under 99:98 (hysteresis)
- CRITICAL if node rating is dropping under 98:85 (hysteresis)

> Elrond node Leader blocks proposed versus blocks accepted dropping
- WARNING if leader blocks proposed versus blocks accepted are greater than 01:02 (hysteresis)
- CRITICAL if leader blocks proposed versus blocks accepted are greater than 02:05 (hysteresis)

> Elrond node Validator blocks signed versus blocks accepted dropping
- WARNING if validator blocks signed versus blocks accepted are greater than 10:20 (hysteresis)
- CRITICAL if validator blocks signed versus blocks accepted are greater than 20:250 (hysteresis)

> Elrond node peers dropping
- WARNING if peers are dropping under 45:40 (hysteresis)
- CRITICAL if peers are dropping under 40:30 (hysteresis)


Alarms can be configured with the following command:
sudo nano /etc/netdata/health.d/elrond.conf

Then,
To reload only the health monitoring component execute:
sudo killall -USR2 netdata

Alternatively you can restart netdata with:  
sudo systemctl restart netdata

----------------------------------------------------------------------
Versions:

v.5.0
- Script checks for Elrond go script node installation and starts the installation only if prefs.toml config file is present.
- Elrond node charts are procedural generated now. Any number of nodes can be monitored now on one server.
- Added the possibility to set your own mainnet or testnet API IP/domain.
- Elrond chart metrics now have elrond prefix for easier finding in Netdata cloud.
- Elrond netdata config file is now procedural generated and includes the node names for an easier indentification in telegram alarms.
- Some code cleaning. 

v.4.2
- script update: sudo chown -R $USER $HOME

v.4.1
- netdata install script improvement to prevent an unistall/reinstall bug

v.4.0
- up to 4 nodes per host monitoring configuration
- code improvements

v.3.0
- up to 2 nodes per host monitoring configuration

v.2.2
- updated official testnet API

v.2.1
- added the option to select network type: Mainnet / Testnet

v.1.10
- ufw opens port 80
- get IPv4 using a more reliable command

v.1.9
-Some code polish

v.1.8
- Get public IP address and display it at Netdata configuration information. 

v.1.7
- Removed ufw activation
- Added more explanatory input text
- Code improvements

v.1.6
- Removed enabling ufw
- Added more explanatory text
- Other various improvements

v.1.5
- Added the possibility to set up the SSH port or other port or range ports

v.1.4
- automate the setup of ufw

v.1.3
- bypass yes/no prompts for linux update and apache nginx install
- change command to get IP4 address

v.1.2
- Setting the firewall for Elrond nodes discovery (ufw allow 37373:38383/tcp)

v.1.1
- Apache nginx install & configuration

v.1.0 
- Linux update
- Setting the hostname
- Setting Netdata chart & config files
- Setting telegram alerts & notifications
