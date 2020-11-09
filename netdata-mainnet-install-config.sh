#!/bin/bash
# Netdata install & config script - Elrond Nodes - ddigital nodes
# powered by Disruptive Digital (c) 2020
# v.2.1

# Starting...
printf "Updating Linux..."
sudo chown -R $USER /home
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt -y autoremove && sudo apt-get -y autoclean

# declare HOSTNAME variable
printf "\nSetting up the hostname. This is the name that appears in the Netdata dashboard in the Node Name heading."
HOSTNAME=$(hostname -s)
printf "The current hostname for this machine is <$HOSTNAME>. Please input the new hostname or leave it blank if don't want to change it: "
read  qhost

# bash check if change hostname
if [ -n "$qhost" ]; then
	printf "Changing hostname to $qhost"
	sudo hostnamectl set-hostname $qhost
else
	printf "Hostname remained unchanged."
fi

printf "Installing/updating Netdata (stable channel, disabled telemetry)..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry

# Apache nginx install
printf "Installing/updating nginx apache"
sudo apt install -y nginx apache2-utils

printf "\nIn order to access your Netdata dashboard, you need to create an username and a password for nginx apache..."
printf "\nPlease input the apache/nginx username: "
read username
sudo htpasswd -c /etc/nginx/.htpasswd $username

printf "Confirming that the username-password pair has been created..."
cat /etc/nginx/.htpasswd

printf "Verifying the nginx configuration to check if everything is ok..."
sudo nginx -t

# bash check if directory exists
printf "\nDownloading Disruptive Digital script & configuration files..."

directory="/home/ubuntu/custom_netdata/"

if [ -d $directory ]; then
        printf "\ncustom_netdata directory exists..."
else
        printf "\ncustom_netdata directory does not exists. Creating now..."
	mkdir -p ~/custom_netdata
fi

cd ~/custom_netdata && rm -rf dd-netdata-monitoring-mainnet-erdapi


# Cloning github files
git clone https://github.com/disruptivedigital/dd-netdata-monitoring-mainnet-erdapi.git

# Assign the IP address to nginx.conf
ip4=$(ip route get 1 | awk '{print $(NF-2);exit}')
# ip4=${ip4:0:-1}
printf "\nServer IP address is <$ip4>."
cd ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi
sed -i "s/my-ip-address/$ip4/" nginx.conf

# Setting telegram bot token & recipient
printf "\nPlease input TELEGRAM BOT TOKEN (example: 1234567890:Aa1BbCc2DdEe3FfGg4HhIiJjKkLlMmNnOoP): "
read  tbt
cd ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi
sed -i "s/telegram-token-placeholder/$tbt/" health_alarm_notify.conf

printf "\nPlease input TELEGRAM DEFAULT RECIPIENT (example: 123456789): "
read  tdr
cd ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi
sed -i "s/telegram-recipient-placeholder/$tdr/" health_alarm_notify.conf


# Copy the chart & config files
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/elrond.chart.sh /usr/libexec/netdata/charts.d/
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/charts.d.conf /usr/libexec/netdata/charts.d/

sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/cpu.conf /etc/netdata/health.d/
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/disks.conf /etc/netdata/health.d/
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/ram.conf /etc/netdata/health.d/
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/tcp_resets.conf /etc/netdata/health.d/

sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/netdata.conf /etc/netdata/
sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/health_alarm_notify.conf /etc/netdata/

sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/nginx.conf /etc/nginx/


# Query if node network type is Mainnet or Testnet and copy the correct file
# Declare variable networktype and assign value 3
printf "\nEstablishing network type (Mainnet / Testnet) \n"
networktype=3
# Print to stdout
printf "\n1. Mainnet"
printf "\n2. Testnet"
printf "\nPlease choose network type [1 or 2]? "
# Loop while the variable networktype is equal 3
# bash while loop
while [ $networktype -eq 3 ]; do

# read user input
read networktype
# bash nested if/else
if [ $networktype -eq 1 ] ; then

        printf "\nNetwork type: Mainnet"
		
else

        if [ $networktype -eq 2 ] ; then
                 printf "\nNetwork type: Testnet"
				 cd /usr/libexec/netdata/charts.d/
				 sudo sed -i "s/api/api-testnet/" elrond.chart.sh
				
        else
                        printf "\nPlease make a choice between 1-2 !"
                        printf "\n1. Mainnet"
                        printf "\n2. Testnet"
                        printf "\nPlease choose node type [1 or 2] ?"
                        networktype=3
        fi
fi
done


# Query if node type is Observer or Validator and cp the correct file
# Declare variable nodetype and assign value 3
printf "\nEstablishing node type (Observer / Validator) \n"
nodetype=3
# Print to stdout
printf "\n1. Observer"
printf "\n2. Validator"
printf "\nPlease choose node type [1 or 2]? "
# Loop while the variable nodetype is equal 3
# bash while loop
while [ $nodetype -eq 3 ]; do

# read user input
read nodetype
# bash nested if/else
if [ $nodetype -eq 1 ] ; then

        printf "\nNode type: Observer"
		sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/elrond-obs.conf /etc/netdata/health.d/elrond.conf

else

        if [ $nodetype -eq 2 ] ; then
                 printf "\nNode type: Validator"
				 sudo cp ~/custom_netdata/dd-netdata-monitoring-mainnet-erdapi/elrond.conf /etc/netdata/health.d/
        else
                        printf "\nPlease make a choice between 1-2 !"
                        printf "\n1. Observer"
                        printf "\n2. Validator"
                        printf "\nPlease choose node type [1 or 2] ?"
                        nodetype=3
        fi
fi
done

sudo systemctl stop netdata && cd /var/cache/netdata && sudo rm -rf *
cd /usr/libexec/netdata/charts.d/ && sudo chmod +x elrond.chart.sh && sudo chmod 755 elrond.chart.sh
sudo systemctl restart netdata
sudo systemctl reload nginx
rm -rf ~/erd-dd-netdata-install ~/custom_netdata

# Setting the firewall for Elrond nodes discovery
printf "\nOpening port 80 for nginx access..."
sudo ufw allow 80/tcp
shopt -s nocasematch
printf "\nDo you want to configure firewall for nodes discovery now? (y|n) "
read  qufw
if [[ $qufw == "y" ]]; then
	printf "\nOpening ports range 37373:38383/tcp and activating ufw..."
	sudo apt install -y ufw
	sudo ufw allow 37373:38383/tcp
	
	# Open secret SSH port or standard (22) port
	printf "\nSetting up the SSH port / other ports..."
	printf "\nPlease input your SSH port (range ports example 37:38) or leave it blank if don't want to change it: "
	read  sshport

		# bash check if change hostname
		if [ -n "$sshport" ]; then
			printf "\nChanging SSH port to $sshport"
			sudo ufw allow $sshport/tcp
		else
			printf "\nSSH port remained unchanged."
		fi
	
	#sudo ufw --force enable
	sudo ufw status verbose
else
	printf "\nFirewall setup skipped."
fi


# Testing telegram notifications
shopt -s nocasematch
printf "\nDo you want to test telegram notifications now? (y|n) "
read  tnotif
if [[ $tnotif == "y" ]]; then
	printf "\nYou should receive some telegram alerts..."
	/usr/libexec/netdata/plugins.d/alarm-notify.sh test
else
	printf "\nNo telegram alert was sent."
fi
cd ~
myextip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
printf "\nNetdata monitoring access:\nhttp://${myextip} \nUsername: $username \nPassword: not-displayed-here"
printf "\nNetdata installation complete. Configuration, script files and alerts succesfuly installed.\n"