#!/bin/bash
set -e

# Start Redis database required by Tanner
service redis-server start

export DOCKER_HOST="tcp://10.0.20.21:8090"

# Start the required Tanner services concurrently
cd /opt/tanner/phpox.git
python3 sandbox.py &

cd /opt/tanner
tannerapi &
tannerweb &
tanner
