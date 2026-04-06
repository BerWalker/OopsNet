#!/bin/bash

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== STARTING OOPSNET INFRASTRUCTURE ===${NC}"

echo -e "\n${YELLOW}[+] STEP 1: Performing Pre-check Cleanup...${NC}"
./scripts/cleanup-docker.sh

echo -e "\n${YELLOW}[+] STEP 2: Preparing Shared Log Directories...${NC}"
mkdir -p ./logs/{dionaea,tanner,snare,kippo/tty}
sudo chmod -R 777 ./logs 2>/dev/null || true

echo -e "\n${YELLOW}[+] STEP 3: Validating Infrastructure Configuration...${NC}"
docker compose config -q || { echo -e "  [${RED}ERROR${NC}] Docker Compose validation failed!"; exit 1; }

echo -e "\n${YELLOW}[+] STEP 4: Building and Starting Services...${NC}"
docker compose up -d

echo -e "\n${YELLOW}[+] STEP 5: Services initializing (Waiting 5s)...${NC}"
sleep 5

echo -e "\n${YELLOW}[+] STEP 6: Running Automated Security Audit...${NC}"
./scripts/network_check-docker.sh

echo -e "\n${GREEN}=== ALL PROCESSES COMPLETED SUCCESSFULLY ===${NC}"
echo -e "${BLUE}You can run honeypot-specific tests now:${NC}"
echo -e "  ./scripts/test-dionaea.sh"
echo -e "  ./scripts/test-tannersnare.sh"
echo -e "  ./scripts/test-kippo.sh"