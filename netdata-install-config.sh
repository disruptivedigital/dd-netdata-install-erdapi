#!/bin/bash
# Netdata install & config script - Mainnet & Testnet Elrond Nodes
# powered by Disruptive Digital (c) 2020-2021 | join our tech telegram group here https://t.me/disruptivedigital_vtc
# v.5.0

# Checking if Elrond Script is present
if [ ! -f "/$HOME/elrond-nodes/node-0/config/prefs.toml" ]
then
	echo "Elrond nodes script is not correctly installed or configured. Please follow the installation details here: https://docs.elrond.com/validators/overview/ 
The installer will exit..."
	exit
else
	echo "Elrond nodes script detected. Netdata monitoring installation for Elrond nodes is starting... "
fi

# Starting...
printf "Updating Linux..."
sudo chown -R $USER $HOME
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt -y autoremove && sudo apt-get -y autoclean

# declare HOSTNAME variable
printf "\nSetting up the hostname. This is the name that appears in the Netdata dashboard in the Node Name heading."
HOSTNAME=$(hostname -s)
printf "\nThe current hostname for this machine is <$HOSTNAME>. Please input the new hostname or leave it blank if don't want to change it: "
read qhost

# bash check if change hostname
if [ -n "$qhost" ]; then
	printf "Changing hostname to $qhost"
	sudo hostnamectl set-hostname $qhost
else
	printf "Hostname remained unchanged."
fi

printf "Installing/updating Netdata (stable channel, disabled telemetry)..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry --allow-duplicate-install

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

# Assign the IP address to nginx.conf
ip4=$(ip route get 1 | awk '{print $(NF-2);exit}')
# ip4=${ip4:0:-1}
printf "\nServer IP address is <$ip4>."
cd ~/dd-netdata-install-erdapi
sed -i "s/my-ip-address/$ip4/" nginx.conf

# Setting telegram bot token & recipient
printf "\nPlease input TELEGRAM BOT TOKEN (example: 1234567890:Aa1BbCc2DdEe3FfGg4HhIiJjKkLlMmNnOoP): "
read tbt
cd ~/dd-netdata-install-erdapi
sed -i "s/telegram-token-placeholder/$tbt/" health_alarm_notify.conf

printf "\nPlease input TELEGRAM DEFAULT RECIPIENT - Group ID (example: -123456789) or User ID (example: 123456789): "
read tdr
cd ~/dd-netdata-install-erdapi
sed -i "s/telegram-recipient-placeholder/$tdr/" health_alarm_notify.conf


# Copy the chart & config files

# Query how many nodes per host and copy the correct files
# Declare variable numberofnodes and assign value 0
printf "\nHow many nodes are you running on the host? \n"
numberofnodes=0
# Loop while the variable numberofnodes is equal 0
# bash while loop
while [ $numberofnodes -eq 0 ]; do

# read user input
read numberofnodes
# bash nested if/else
if [ "$numberofnodes"  -ge 1 ] 2>/dev/null; 
then
    printf "\nCreating the Elrond chart file for $numberofnodes node(s)\n"
	cd ~/dd-netdata-install-erdapi/
	bash dd-gen-erdcharts-v1.sh $numberofnodes
	sudo cp ~/dd-netdata-install-erdapi/elrond.chart.sh /usr/libexec/netdata/charts.d/
	# declare variable for elrond.conf file identification
else
	numberofnodes=0
	echo "Input interger greater than 0"
fi
done


# Copy the rest of the files
sudo cp ~/dd-netdata-install-erdapi/charts.d.conf /usr/libexec/netdata/charts.d/
sudo cp ~/dd-netdata-install-erdapi/cpu.conf /etc/netdata/health.d/
sudo cp ~/dd-netdata-install-erdapi/disks.conf /etc/netdata/health.d/
sudo cp ~/dd-netdata-install-erdapi/ram.conf /etc/netdata/health.d/
sudo cp ~/dd-netdata-install-erdapi/tcp_resets.conf /etc/netdata/health.d/
sudo cp ~/dd-netdata-install-erdapi/netdata.conf /etc/netdata/
sudo cp ~/dd-netdata-install-erdapi/health_alarm_notify.conf /etc/netdata/
sudo cp ~/dd-netdata-install-erdapi/nginx.conf /etc/nginx/

# Query if node network type is Mainnet or Testnet and make the adjustments
# Declare variable networktype and assign value 0
printf "\nEstablishing network type (Mainnet / Testnet) \n"
networktype=0
# Print to stdout
printf "\n1. Mainnet"
printf "\n2. Testnet"
printf "\nPlease choose network type [1 or 2]? "
# Loop while the variable networktype is equal 0
# bash while loop
while [ $networktype -eq 0 ]; do

# read user input
read networktype
# bash nested if/else
if [ $networktype -eq 1 ] ; then
		printf "\nNetwork type: Mainnet. Please input your personal API including the port (example: http://192.168.1.1:8080; https://myAPI.do) or leave it blank if you want to use the Elrond mainnet API: "
		read mAPI
		# bash check if change API
		if [ -n "$mAPI" ]; then
			printf "\nSetting API to $mAPI\n"
			sudo sed -i "s/https:\/\/api\.elrond\.com/$mAPI/" /usr/libexec/netdata/charts.d/elrond.chart.sh
		else
			printf "\nUsing Elrond mainnet API.\n"
		fi
else

        if [ $networktype -eq 2 ] ; then
			printf "\nNetwork type: Testnet. Please input your personal API including the port (example: http://192.168.1.1:8080; https://myAPI.do) or leave it blank if you want to use the Elrond testnet API: "
			read tAPI
			# bash check if change API
				if [ -n "$tAPI" ]; then
					printf "\nSetting API to $tAPI\n"
					sudo sed -i "s/https:\/\/api\.elrond\.com/$tAPI/" /usr/libexec/netdata/charts.d/elrond.chart.sh
				else
					sudo sed -i "s/api/testnet-api/" /usr/libexec/netdata/charts.d/elrond.chart.sh
					printf "\nUsing Elrond testnet API.\n"
				fi
        else
			printf "\nPlease make a choice between 1-2!"
            printf "\n1. Mainnet"
			printf "\n2. Testnet"
			printf "\nPlease choose node type [1 or 2] "
			networktype=0
        fi
fi
done


# Query if node type is Observer or Validator and copy the correct files
# Declare variable nodetype and assign value 0
printf "\nEstablishing node type (Observer / Validator) \n"
nodetype=0
# Print to stdout
printf "\n1. Observer node(s)"
printf "\n2. Validator node(s)"
printf "\nPlease choose node type [1 or 2]? "
# Loop while the variable nodetype is equal 0
# bash while loop
while [ $nodetype -eq 0 ]; do
# read user input
read nodetype
# bash nested if/else
if [ $nodetype -eq 1 ] ; then
		printf "\nNode type: Observer\n"
		cd ~/dd-netdata-install-erdapi/
		bash dd-gen-erdocfg-v1.sh $numberofnodes
		sudo cp ~/dd-netdata-install-erdapi/elrond.conf /etc/netdata/health.d/
else
		if [ $nodetype -eq 2 ] ; then
			printf "\nNode type: Validator\n"
			cd ~/dd-netdata-install-erdapi/
			bash dd-gen-erdvcfg-v1.sh $numberofnodes
			sudo cp ~/dd-netdata-install-erdapi/elrond.conf /etc/netdata/health.d/
        else
                        printf "\nPlease make a choice between 1-2!"
                        printf "\n1. Observer"
                        printf "\n2. Validator"
                        printf "\nPlease choose node type [1 or 2] ?"
                        nodetype=0
        fi
fi
done

sudo systemctl stop netdata && cd /var/cache/netdata && sudo rm -rf *
cd /usr/libexec/netdata/charts.d/ && sudo chmod +x elrond.chart.sh && sudo chmod 755 elrond.chart.sh
sudo systemctl restart netdata
sudo systemctl reload nginx
sudo rm -rf ~/dd-netdata-install-erdapi

# Setting the firewall for Elrond nodes discovery
printf "\nOpening port 80 for nginx access..."
sudo ufw allow 80/tcp
shopt -s nocasematch
printf "\nDo you want to configure firewall for nodes discovery now? (y|n) "
read qufw
if [[ $qufw == "y" ]]; then
	printf "\nOpening ports range 37373:38383/tcp and activating ufw..."
	sudo apt install -y ufw
	sudo ufw allow 37373:38383/tcp

	# Open custom SSH port or standard (22) port
	printf "\nSetting up the SSH port / other ports..."
	printf "\nPlease input your SSH port or leave it blank if don't want to change it: "
	read sshport

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
read tnotif
if [[ $tnotif == "y" ]]; then
	printf "\nYou should receive some telegram alerts..."
	/usr/libexec/netdata/plugins.d/alarm-notify.sh test
else
	printf "\nNo telegram alert was sent."
fi
cd ~
myextip="$(curl ifconfig.me)"
printf "\nNetdata monitoring access:\nhttp://${myextip} \nUsername: $username \nPassword: not-displayed-here"
printf "\nNetdata installation complete. Configuration, script files and alerts succesfuly installed.\n"
