Folder=`mkdir /opt/uncanny`
#Create_file=`touch /opt/uncanny/lock`
File="/opt/uncanny/lock"
Aikaan="/opt/aikaan"

while true;
do

DATE=`date`

ping -q -c5 google.com > /dev/null

if [ $? -eq 0 ]
then
	DATE=`date`
	echo $DATE
	echo "Internet is working !\n"
	
	sleep 5
		
	if [ -f "$File" ] && [ -d "$Aikaan" ]
	then
		echo "\nAgent has been already installed !"
	else
		#ps=`ps aux | grep aikaan | awk '{print $2}' > /uncanny/pid.txt`
		echo "\nRemoving Agent Folder !"
		rm -rf /opt/aikaan

		echo "\nKilling all the Agent processes !"
		pkill -f aikaan 

		sudo apt-get update -y

		curl -sfkL 'https://monitor.uncannysurveillance.com/api/_external/img/v1/user/fa6a9975-14e2-4b0d-af52-9fdefadc3074/dgp/5b422c4c-d866-43c3-9587-930026d6a7c2/fwshellscript?package_type=ipkg' | sh > /opt/uncanny/Aikaan-installation.log

		check=`cat /opt/uncanny/Aikaan-installation.log | grep "Aiagent installed successfully!"`
		if [ $? -eq 0 ]
		then
			echo "\nAI Agent installed successfully!"
			echo "\n Creating a lock file!"
			Create_file=`touch /opt/uncanny/lock`
			
			token=`curl -k 'https://monitor.uncannysurveillance.com/api/_external/auth/v1/signin' --data-raw '{"email":"uncannyvision@aikaan.io","password":"uncannyvision@123456"}' | jq -r ".data.token"`
			echo $token

			net_status=`cat /sys/class/net/enp*/operstate`; echo "$net_status"

			if [ $net_status = "up" ]
			then
				mac_id=`cat /sys/class/net/enp*/address | head -n 1 | sed -e "s/:/-/g"`; echo "$mac_id"
				description="None"
				filename=`cat /opt/aikaan/etc/aiagent_config.json |  grep -o '"DeviceId":"[^"]*' | grep -o '[^"]*$'`

				#curl 'https://monitor.uncannysurveillance.com/dm/api/dm/v1/device/'$filename'' -X 'PUT' -H 'authority: monitor.uncannysurveillance.com' -H 'accept: application/json, text/plain, */*' -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' -H 'content-type: application/x-www-form-urlencoded' -H 'cookie: ajs_anonymous_id=5dadeecc-78ee-4bcd-aa6b-f14d32d972ae; webptzmode=continuous; activatedmode=digital; g_mode=1; viewsizemode=100; 4x3=false; username=admin; framelevel=8; aicon-jwt='$token'; amp_6e403e=a0kiXrIsazfWvGp1xDaM7y...1hbu24md6.1hbu24md6.0.0.0' -H 'origin: https://monitor.uncannysurveillance.com' -H 'referer: https://monitor.uncannysurveillance.com/device/'$filename'/info' -H 'sec-ch-ua: "Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"' -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Linux"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-origin' -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' --data-raw '{"name":"'$mac_id'","desc":"'$description'"}' --compressed
				sleep 20
				curl -k "https://monitor.uncannysurveillance.com/dm/api/dm/v1/device/$filename" -X PUT -H "Cookie: aicon-jwt=$token" --data-raw "{\"name\":\"$mac_id\",\"desc\":\"$description\"}" --compressed

				echo "\nAikaan name changed to : $mac_id"
			else
				echo "\n Please check the network Ethernet port connectivity...."
			fi

		else
			echo "\nSome issue while installation, please check it !"
		fi
	fi
else
	echo "\n$DATE"	
	echo "\nInternet is not working !\nPlease check the connection..."
fi

sleep 20

done
