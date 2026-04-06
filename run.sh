#!/bin/bash

set -e

./scripts/cleanup-docker.sh

docker login

docker compose up -d

./scripts/network_check-docker.sh

echo "Process completed!"