#!/bin/bash
mountpath="/uncanny"
threshold=85
while true;
do
	disk=`df -hT / | awk '{print $6}' | tail -1 | head -c 2`
	if [ $disk -ge $threshold ]
	then 
		echo "\n"
		date
		echo "Alert!!! The disk size has crossed $threshold% of threshold!"
		echo "\nDockers will be stopped - sudo docker-compose down"
		cd $mountpath
		sudo docker-compose down
	else
		echo "\n"
		date
		echo "The current disk size is $disk%"
	fi
	sleep 60
done
