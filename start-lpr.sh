#!/bin/bash
sink_client="/uncanny/sink/client/"
sink_path="/uncanny/sink/"
tcp_config="/uncanny/sink/tcp_config/"
path="/uncanny"
client_adapter="/uncanny/anpr/instance1"
license="/etc/uncanny/license.lic"

if [ -f "$license" ];
   then

	cd $path 
	cp $client_adapter/client_format.py $path/anpr/client_adapter
        docker-compose -f docker-compose.yml pull
        docker-compose -f docker-compose.yml up -d
	sleep 15
	echo "\n LPR service is started...."
        docker ps

        echo "\n **** Backup sink app file ****"
        rm -r $sink_path/tcp_config
        cp $sink_path/pm2_app.json $sink_path/old_pm2_app.json
        echo "\n ** Done ** "

        cd $sink_path
        echo "\n **** Downloading TCP sink configuration file ****"
        wget "https://www.dropbox.com/s/8arwg2s4z6dyphy/tcp_config.zip?dl=0" -O tcp_config.zip
        unzip tcp_config.zip
        echo "\n ** Done ** \n"

        echo "\n **** Replacing TCP sink config file ****"
        #cp $tcp_config/pm2_app.json $sink_path
        cp $sink_client/tcp_server.js $sink_client/old_tcp_server.js
        cp $tcp_config/tcp_server.js $sink_client
        #echo "\n To enable TCP enter the system IP : "
        system_IP=`hostname -I | awk '{print $1}'`
        echo $system_IP
        curl --location --request POST http://$system_IP:8200/api/v1/custom --header 'Content-Type: application/json' --data-raw '{"command": "START_TCP"}'
        echo $cmd

        echo "\n ** Restarting sink module **\n"
        cp $tcp_config/pm2_app.json $sink_path
	curl -sfkL "https://www.dropbox.com/s/tvydnxr296tyvjx/sink_cam_id_update_loop.py?dl=0" | python3
        sudo docker restart sink
        mv $sink_path/tcp_config.zip $path/old_tcp_config.zip
   else
        echo "\nError: license is not activated. Can not continue...."
        exit 1
fi

