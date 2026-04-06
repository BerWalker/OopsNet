#!/bin/bash
set -e

cd /opt/snare

# Clone the actual DMZ webserver to make Snare look legitimate!
echo "Waiting for DMZ web application to start..."
while ! curl -s http://10.0.20.10 > /dev/null; do
    echo "Web application not ready yet, waiting..."
    sleep 2
done

echo "Cloning the DMZ web application..."
clone --target http://10.0.20.10

# Extract the cloned directory name (which is the domain/IP we just cloned)
# Since we cloned an IP, it will be named '10.0.20.10'
PAGE_DIR="10.0.20.10"

echo "Starting Snare on port 8080. Connected to Tanner at 10.0.20.21"
snare --host-ip 0.0.0.0 --port 8080 --page-dir $PAGE_DIR --tanner 10.0.20.21
