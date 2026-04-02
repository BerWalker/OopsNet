#!/bin/bash

set -e

./scripts/cleanup-docker.sh

sudo docker compose up -d

./scripts/network_check-docker.sh

echo "Processo concluído!"