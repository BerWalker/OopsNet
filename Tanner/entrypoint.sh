#!/bin/bash
set -e

service redis-server start

export DOCKER_HOST="tcp://10.0.20.21:8090"

mkdir -p /var/log/tanner
touch /var/log/tanner/tanner.log
chmod 777 /var/log/tanner/tanner.log
ln -sf /var/log/tanner/tanner.log /opt/tanner/tanner.log

cd /opt/tanner/phpox.git
python3 sandbox.py &

cd /opt/tanner
tannerapi &
tannerweb &
tanner
