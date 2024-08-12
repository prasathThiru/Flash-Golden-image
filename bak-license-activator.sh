docker_path="/home/user/uv"
license_path="/etc/uncanny/license.lic"

while true;
do

DATE=`date`

ping -q -c5 google.com > /dev/null

if [ $? -eq 0 ]
then
	echo "installing license docker"
	sudo docker-compose -f $docker_path/license-docker-compose.yml up -d
	sleep 5
	sudo docker ps -a

	echo "Open port 6111 to install the license"
	sleep 30
	if [ -f "$license_path" ]
	then
		echo "license installed - $license_path"
		echo "stopping the license docker"
		sudo docker-compose -f $docker_path/license-docker-compose.yml down
		sudo docker ps -a
		sudo kill -9 `ps aux | grep -i /uncanny/license_activator.sh | awk '{print $2}' | head -1`
	else
		echo "Please install the license.... "
	fi
else
        echo "\n$DATE"  
        echo "\nInternet is not working !\nPlease check the connection..."	

fi
done
