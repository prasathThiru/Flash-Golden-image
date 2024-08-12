#!/bin/bash

# This script changes the hostname, installs LogMeIn, enables device uptime monitoring, and enables the watchdog.
# Last update: 11/30/22
# Author: Andrew Demers - andrew.demers@flashparking.com

# get host name 
echo What would you like to name this device?
read hostname

# set host name
hostnamectl set-hostname $hostname

# confirm hostname 
echo This device is now named $hostname

# enable watchdog
while true
do
	echo ""
	echo Would you like to enable the wathdog device? y/n: 
	read userInput
	if [[ $userInput == y ]] || [[ $userInput == n ]]
	then
		break
	else
		echo Please enter y/n.
	fi
done

if [[ $userInput == y ]]; then
	sudo systemctl enable watchdog
	sudo service watchdog start
	echo Watchdog is now enabled.
fi

# install logmein and configure
while true
do
	echo ""
	echo Would you like to install LogMeIn? y/n:
	read userInput
	if [[ $userInput == y ]] || [[ $userInput == n ]]
        then
               break
	else
		echo Please enter y/n.
	fi
done

if [[ $userInput == y ]]; then
	sudo snap install logmein-host
	sudo snap set logmein-host 'deploy-code=https://secure.logmein.com/i?l=en&c=01_w3gr1f3g0mguzklcvucfectxg5ffd152rs70v'
fi

# enable script for device uptime monitoring
while true 
do
	echo ""
	echo Would you like to enable device monitoring? y/n
	read userInput
	if [[ $userInput == y ]] || [[ $userInput == n ]]
        then
                break
        else
                echo Please enter y/n
        fi
done

if [[ $userInput == y ]]; then
	echo Enter URL from Uptime Kuma: 
	read url

# copy uptime-monitor service 
cat >/etc/systemd/system/uptime-monitor.service<< EOL 
[Unit]
After=network.target

[Service]
ExecStart=/usr/bin/uptime.sh

[Install]
WantedBy=default.target
EOL

# copy uptime script
cat >/usr/bin/uptime.sh<< EOL
#!/bin/bash
while true
do 
	curl $url
	sleep 165
done

EOL

sudo chmod 664 /etc/systemd/system/uptime-monitor.service
sudo chmod +x /usr/bin/uptime.sh

sleep 2

sudo systemctl daemon-reload
sudo systemctl enable uptime-monitor.service
sudo systemctl restart uptime-monitor.service
fi

echo ""
echo Installation is now complete!
