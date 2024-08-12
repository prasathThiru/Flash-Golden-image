docker_path="/uncanny"
license_path="/etc/uncanny/license.lic"
process_killed=false

while true; do
    DATE=$(date)

    ping -q -c5 google.com > /dev/null

    if [ -f "$license_path" ]; then
        echo "\nLicense already installed..."
        echo "\n$license_path\nStopping the license Docker"
        sudo docker-compose -f "$docker_path/license-docker-compose.yml" down || { echo "Error stopping Docker container"; exit 1; }
        sudo docker ps -a || { echo "Error listing Docker containers"; exit 1; }
        
        if ! $process_killed; then
            # Find and kill the process associated with license_activator.sh
            PID=$(ps aux | grep -i "license_activator.sh" | grep -v grep | awk '{print $2}' | head -1)
            if [ -n "$PID" ]; then
                sudo kill -9 "$PID" || { echo "Error killing process $PID"; exit 1; }
                process_killed=true
            fi
        fi
    else
        echo "Installing license Docker"
        sudo docker-compose -f "$docker_path/license-docker-compose.yml" down || { echo "Error stopping Docker container"; exit 1; }
        sudo docker-compose -f "$docker_path/license-docker-compose.yml" up -d || { echo "Error starting Docker container"; exit 1; }
        sleep 5
        sudo docker ps -a || { echo "Error listing Docker containers"; exit 1; }

        echo "Open port 6111 to install the license"
        
        # Wait for the license file to appear, with timeout
        timeout=300  # 300 seconds = 5 minutes
        while [ ! -f "$license_path" ] && [ $timeout -gt 0 ]; do
            sleep 1
            timeout=$((timeout - 1))
        done
        
        if [ ! -f "$license_path" ]; then
            echo "License file not found after waiting. Exiting..."
            exit 1
        fi
    fi
    
    # Sleep to avoid continuous high CPU usage
    sleep 60
done
