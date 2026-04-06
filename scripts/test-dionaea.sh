#!/bin/bash
# Description: Validates Dionaea honeypot functionality by scanning from the external client.

# Color Definitions
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Target Configuration
DIONAEA_IP="10.0.10.20"
CLIENT_CONTAINER="inet-client-01"
DIONAEA_CONTAINER="inet-dionaea-01"

echo -e "${BLUE}[+] STEP 1: Verifying Dionaea container status...${NC}"
docker ps --filter "name=${DIONAEA_CONTAINER}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n${BLUE}[+] STEP 2: Running Service/Version Scan from Internet Client (${CLIENT_CONTAINER})${NC}"
docker exec ${CLIENT_CONTAINER} nmap -sS -Pn -p 21,42,80,443,445,1433,3306 ${DIONAEA_IP}

echo -e "\n${BLUE}[+] STEP 3: Attempting HTTP connection (Port 80)${NC}"
docker exec ${CLIENT_CONTAINER} curl -I -s --connect-timeout 2 http://${DIONAEA_IP} || echo -e "${RED}[INFO] Curl connection closed (expected for honeypot behavior)${NC}"

echo -e "\n${BLUE}[+] STEP 4: Checking Dionaea logs for connection events...${NC}"
docker exec ${DIONAEA_CONTAINER} tail -n 20 /opt/dionaea/var/log/dionaea/dionaea.log

echo -e "\n${BLUE}[OK] DIONAEA TEST COMPLETE${NC}"
